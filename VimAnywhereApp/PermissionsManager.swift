//
//  PermissionsManager.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import CoreGraphics
import ApplicationServices

class PermissionManager {

    static func hasInputMonitoringPermission() -> Bool {
        CGPreflightListenEventAccess()
    }

    static func requestInputMonitoringPermission() -> Bool {
        CGRequestListenEventAccess()
    }

    static func hasPostEventPermission() -> Bool {
        CGPreflightPostEventAccess()
    }

    static func requestPostEventPermission() -> Bool {
        CGRequestPostEventAccess()
    }

    static func hasAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }

    static func requestAccessibilityPermission() -> Bool {
        let options: CFDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        return AXIsProcessTrustedWithOptions(options)
    }
}
