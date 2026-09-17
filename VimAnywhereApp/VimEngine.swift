//
//  VimEngine.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/16/26.
//

import Foundation
import CoreGraphics
import Combine

enum VimMode {
    case normal
    case insert
}

enum PendingCommand {
    case none
    case delete
    case change
    case go
}

class VimEngine: ObservableObject {

    @Published var mode: VimMode = .normal
    @Published var pendingCommand: PendingCommand = .none

    func enterNormalMode() {
        mode = .normal
        pendingCommand = .none
        print("NORMAL MODE")
    }

    func enterInsertMode() {
        mode = .insert
        pendingCommand = .none
        print("INSERT MODE")
    }
}
