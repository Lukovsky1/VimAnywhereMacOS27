//
//  FocusedElementManager.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import Foundation
import AppKit
import ApplicationServices

class FocusedElementManager {

    static func isTextInputFocused() -> Bool {

        guard AXIsProcessTrusted() else {
            print("AX: Accessibility permission is not active")
            return false
        }

        // Get the currently active application using AppKit
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            print("AX: Could not determine frontmost application")
            return false
        }

        let pid = frontmostApp.processIdentifier

        print("Frontmost app:", frontmostApp.localizedName ?? "Unknown")
        print("PID:", pid)

        // Create an Accessibility object directly for that app
        let appElement = AXUIElementCreateApplication(pid)

        var focusedValue: CFTypeRef?

        let focusedResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedValue
        )

        guard focusedResult == .success,
              let focusedValue = focusedValue else {

            print(
                "AX: Could not get focused UI element:",
                focusedResult.rawValue
            )

            return false
        }

        let focusedElement = focusedValue as! AXUIElement

        // Ask what kind of UI element it is
        var roleValue: CFTypeRef?

        let roleResult = AXUIElementCopyAttributeValue(
            focusedElement,
            kAXRoleAttribute as CFString,
            &roleValue
        )

        guard roleResult == .success,
              let role = roleValue as? String else {

            print(
                "AX: Could not get focused element role:",
                roleResult.rawValue
            )

            return false
        }

        print("FOCUSED ROLE:", role)

        return role == kAXTextFieldRole as String ||
               role == kAXTextAreaRole as String
    }
}
