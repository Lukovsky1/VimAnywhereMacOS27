//
//  InputMonitoringManager.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import CoreGraphics

class InputMonitoringManager {

    static func hasPermission() -> Bool {
        return CGPreflightListenEventAccess()
    }

    static func requestPermission() -> Bool {
        return CGRequestListenEventAccess()
    }
}
