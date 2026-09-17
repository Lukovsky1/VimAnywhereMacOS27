//
//  ModeIndicatorView.swift
//  VimAnywhereApp
//
//  Created by Lucas Ulibarri on 9/17/26.
//

import SwiftUI

struct ModeIndicatorView: View {

    @ObservedObject var vimEngine: VimEngine

    var body: some View {
        Text(vimEngine.mode == .normal ? "NORMAL" : "INSERT")
            .font(.system(size: 16, weight: .bold))
            .frame(minWidth: 100, minHeight: 36)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
