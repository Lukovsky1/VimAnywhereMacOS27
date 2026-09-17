//
//  KeyboardManager.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import Foundation
import CoreGraphics

class KeyboardManager {

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    var vimEngine: VimEngine

    init(vimEngine: VimEngine) {
        self.vimEngine = vimEngine
    }

    func startListening() {

        let keyDownMask = CGEventMask(
            1 << CGEventType.keyDown.rawValue
        )

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: keyDownMask,
            callback: { proxy, type, event, userInfo in

                guard let userInfo = userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let manager = Unmanaged<KeyboardManager>
                    .fromOpaque(userInfo)
                    .takeUnretainedValue()

                return manager.handleKeyEvent(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap = eventTap else {
            print("Could not create event tap.")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
        )

        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            runLoopSource,
            .commonModes
        )

        CGEvent.tapEnable(
            tap: eventTap,
            enable: true
        )

        print("Keyboard listener started.")
    }

    private func handleKeyEvent(
        _ event: CGEvent
    ) -> Unmanaged<CGEvent>? {

        let keyCode = event.getIntegerValueField(
            .keyboardEventKeycode
        )

        let flags = event.flags

        // Only use Vim commands while editing text.
        if !FocusedElementManager.isTextInputFocused() {
            return Unmanaged.passUnretained(event)
        }

        // Always allow normal macOS Command shortcuts.
        if flags.contains(.maskCommand) {
            return Unmanaged.passUnretained(event)
        }

        // -------------------------
        // INSERT MODE
        // -------------------------

        if vimEngine.mode == .insert {

            // Escape
            if keyCode == 53 {
                vimEngine.enterNormalMode()
                return nil
            }

            // Everything else types normally.
            return Unmanaged.passUnretained(event)
        }

        // -------------------------
        // NORMAL MODE
        // -------------------------

        // -------------------------
        // HANDLE PENDING COMMANDS
        // -------------------------

        if vimEngine.pendingCommand == .delete {

            switch keyCode {

            case 2: // dd
                deleteCurrentLine()
                vimEngine.pendingCommand = .none
                return nil

            case 13: // dw
                deleteWordForward()
                vimEngine.pendingCommand = .none
                return nil

            case 21: // d$
                deleteToEndOfLine()
                vimEngine.pendingCommand = .none
                return nil

            case 29: // d0
                deleteToBeginningOfLine()
                vimEngine.pendingCommand = .none
                return nil

            default:
                // Invalid d combination.
                // Cancel delete mode and process this key normally.
                vimEngine.pendingCommand = .none
            }
        }

        if vimEngine.pendingCommand == .go {

            if keyCode == 5 { // gg

                sendModifiedKey(
                    126,
                    modifier: .maskCommand
                )

                vimEngine.pendingCommand = .none
                return nil
            }

            // Anything besides the second g cancels gg.
            // The current key will still be processed below.
            vimEngine.pendingCommand = .none
        }
        
        if vimEngine.pendingCommand == .change {

            switch keyCode {

            case 13: // cw
                changeWordForward()
                vimEngine.pendingCommand = .none
                return nil

            case 21: // c$
                changeToEndOfLine()
                vimEngine.pendingCommand = .none
                return nil

            case 29: // c0
                changeToBeginningOfLine()
                vimEngine.pendingCommand = .none
                return nil

            default:
                vimEngine.pendingCommand = .none
            }
        }

        // -------------------------
        // NORMAL MODE COMMANDS
        // -------------------------

        switch keyCode {

        case 4: // h
            sendKey(123) // Left
            return nil

        case 38: // j
            sendKey(125) // Down
            return nil

        case 40: // k
            sendKey(126) // Up
            return nil

        case 37: // l
            sendKey(124) // Right
            return nil

        case 34: // i / I

            if flags.contains(.maskShift) {

                // I = beginning of line, then Insert mode
                sendModifiedKey(
                    123,
                    modifier: .maskCommand
                )

                vimEngine.enterInsertMode()

            } else {

                // i = Insert mode at current position
                vimEngine.enterInsertMode()
            }

            return nil

        case 13: // w
            sendModifiedKey(
                124,
                modifier: .maskAlternate
            )
            return nil

        case 11: // b
            sendModifiedKey(
                123,
                modifier: .maskAlternate
            )
            return nil

        case 29: // 0
            sendModifiedKey(
                123,
                modifier: .maskCommand
            )
            return nil

        case 21: // $
            sendModifiedKey(
                124,
                modifier: .maskCommand
            )
            return nil

        case 7: // x
            sendKey(117) // Forward Delete
            return nil

        case 0: // a / A

            if flags.contains(.maskShift) {

                // A = end of line, then Insert mode
                sendModifiedKey(
                    124,
                    modifier: .maskCommand
                )

                vimEngine.enterInsertMode()

            } else {

                // a = move right one character, then Insert mode
                sendKey(124)

                vimEngine.enterInsertMode()
            }

            return nil

        case 2: // d

            // Wait for another key:
            // dd, dw, d$, d0
            vimEngine.pendingCommand = .delete
            return nil

        case 31: // o / O

            if flags.contains(.maskShift) {

                // -------------------------
                // O = open line above
                // -------------------------

                // Beginning of current line
                sendModifiedKey(
                    123,
                    modifier: .maskCommand
                )

                // Create newline
                sendKey(36)

                // Move to newly created line
                sendKey(126)

                vimEngine.enterInsertMode()

            } else {

                // -------------------------
                // o = open line below
                // -------------------------

                // End of current line
                sendModifiedKey(
                    124,
                    modifier: .maskCommand
                )

                // Create newline
                sendKey(36)

                vimEngine.enterInsertMode()
            }

            return nil

        case 5: // g / G

            if flags.contains(.maskShift) {

                // G = bottom of document
                sendModifiedKey(
                    125,
                    modifier: .maskCommand
                )

                vimEngine.pendingCommand = .none

            } else {

                // First g.
                // Wait to see whether another g follows.
                vimEngine.pendingCommand = .go
            }

            return nil
            
        case 8: // c
            vimEngine.pendingCommand = .change
            return nil
            
        case 32: // u
            sendModifiedKey(
                6, // z
                modifier: .maskCommand
            )
            return nil

        case 15: // r / R
            if flags.contains(.maskShift) {

                // Shift+R = redo
                sendModifiedKey(
                    6, // z
                    modifier: [.maskCommand, .maskShift]
                )

                return nil
            }

            // lowercase r can be implemented later
            return Unmanaged.passUnretained(event)

        default:

            // Unknown commands currently pass through.
            return Unmanaged.passUnretained(event)
        }
    }

    // MARK: - Synthetic Keyboard Events

    private func sendKey(
        _ keyCode: CGKeyCode
    ) {

        let source = CGEventSource(
            stateID: .privateState
        )

        let keyDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: keyCode,
            keyDown: true
        )

        let keyUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: keyCode,
            keyDown: false
        )

        // Do not inherit physical modifiers.
        keyDown?.flags = []
        keyUp?.flags = []

        keyDown?.post(
            tap: .cgSessionEventTap
        )

        keyUp?.post(
            tap: .cgSessionEventTap
        )
    }

    private func sendModifiedKey(
        _ keyCode: CGKeyCode,
        modifier: CGEventFlags
    ) {

        let source = CGEventSource(
            stateID: .privateState
        )

        let keyDown = CGEvent(
            keyboardEventSource: source,
            virtualKey: keyCode,
            keyDown: true
        )

        let keyUp = CGEvent(
            keyboardEventSource: source,
            virtualKey: keyCode,
            keyDown: false
        )

        // Use only the modifiers we explicitly specify.
        keyDown?.flags = modifier
        keyUp?.flags = modifier

        keyDown?.post(
            tap: .cgSessionEventTap
        )

        keyUp?.post(
            tap: .cgSessionEventTap
        )
    }

    // MARK: - Vim Delete Commands

    private func deleteCurrentLine() {

        // Beginning of current line
        sendModifiedKey(
            123,
            modifier: .maskCommand
        )

        // Select current line and newline
        sendModifiedKey(
            125,
            modifier: .maskShift
        )

        // Delete selection
        sendKey(51)
    }

    private func deleteWordForward() {

        // Move to beginning of current word
        sendModifiedKey(
            123,
            modifier: .maskAlternate
        )

        // Select forward one word
        sendModifiedKey(
            124,
            modifier: [.maskAlternate, .maskShift]
        )

        // Delete selection
        sendKey(51)
    }

    private func deleteToEndOfLine() {

        // Select from cursor to end of line
        sendModifiedKey(
            124,
            modifier: [.maskCommand, .maskShift]
        )

        // Delete selection
        sendKey(51)
    }

    private func deleteToBeginningOfLine() {

        // Select from cursor to beginning of line
        sendModifiedKey(
            123,
            modifier: [.maskCommand, .maskShift]
        )

        // Delete selection
        sendKey(51)
    }
    
    private func changeWordForward() {

        // Move to beginning of current word
        sendModifiedKey(
            123,
            modifier: .maskAlternate
        )

        // Select forward one word
        sendModifiedKey(
            124,
            modifier: [.maskAlternate, .maskShift]
        )

        // Delete selection
        sendKey(51)

        vimEngine.enterInsertMode()
    }

    private func changeToEndOfLine() {

        sendModifiedKey(
            124,
            modifier: [.maskCommand, .maskShift]
        )

        sendKey(51)

        vimEngine.enterInsertMode()
    }

    private func changeToBeginningOfLine() {

        sendModifiedKey(
            123,
            modifier: [.maskCommand, .maskShift]
        )

        sendKey(51)

        vimEngine.enterInsertMode()
    }
}
