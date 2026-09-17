//
//  AccessibilityManager.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import Foundation
import ApplicationServices

class AccessibilityManager {

    static func requestPermission() -> Bool {
        let options: CFDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        let trusted = AXIsProcessTrustedWithOptions(options)

        print("AX trusted:", trusted)

        return trusted
    }
}
