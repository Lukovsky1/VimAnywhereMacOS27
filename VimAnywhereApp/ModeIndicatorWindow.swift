//
//  ModeIndicatorWindow.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/17/26.
//

import AppKit
import SwiftUI

class ModeIndicatorWindow {

    private var window: NSWindow?

    func show(vimEngine: VimEngine) {

        let view = ModeIndicatorView(vimEngine: vimEngine)

        let hostingView = NSHostingView(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(
                x: 20,
                y: 20,
                width: 140,
                height: 50
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.contentView = hostingView
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true

        window.ignoresMouseEvents = true

        window.orderFrontRegardless()

        self.window = window
    }
}
