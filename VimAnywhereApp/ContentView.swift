//
//  ContentView.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import SwiftUI

struct ContentView: View {

    let vim: VimEngine
    let keyboard: KeyboardManager
    let indicator: ModeIndicatorWindow

    init() {
        let engine = VimEngine()
        let indicatorWindow = ModeIndicatorWindow()

        self.vim = engine
        self.keyboard = KeyboardManager(vimEngine: engine)
        self.indicator = indicatorWindow

        indicatorWindow.show(vimEngine: engine)
    }

    var body: some View {
        VStack(spacing: 20) {

            Text("VimAnywhere")
                .font(.largeTitle)

            Button("Start Keyboard Listener") {
                keyboard.startListening()
            }

            Button("Normal Mode") {
                vim.enterNormalMode()
            }

            Button("Insert Mode") {
                vim.enterInsertMode()
            }
            
            Button("Check Permissions") {
                print("Input Monitoring:",
                      PermissionManager.hasInputMonitoringPermission())

                print("Post Event:",
                      PermissionManager.hasPostEventPermission())

                print("Accessibility:",
                      PermissionManager.hasAccessibilityPermission())
            }
            
            Button("Request Input Monitoring") {
                let result = PermissionManager.requestInputMonitoringPermission()
                print("Input Monitoring request:", result)
            }

            Button("Request Post Event") {
                let result = PermissionManager.requestPostEventPermission()
                print("Post Event request:", result)
            }

            Button("Request Accessibility") {
                let result = PermissionManager.requestAccessibilityPermission()
                print("Accessibility request:", result)
            }
            
        }
        .padding(40)
    }
}
