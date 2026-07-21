//
//  SystemOnlineView.swift
//  QuantumCore
//
//  Animação do clímax: "QUANTUM CORE ONLINE" pulsando no verde do status
//  SYSTEM ONLINE do protótipo (#00E23F), com glow.
//

import SwiftUI

struct SystemOnlineView: View {

    @State private var isBlinking = false

    private let online = Color(hex: 0x00E23F)

    var body: some View {
        VStack(spacing: 8) {
            Text("QUANTUM CORE")
                .font(.custom(AppFonts.button, size: 48))
                .foregroundStyle(isBlinking ? online : StartPalette.cream.opacity(0.7))
                .shadow(color: online.opacity(isBlinking ? 0.8 : 0), radius: 14)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBlinking)

            Text("ONLINE")
                .font(.custom(AppFonts.button, size: 48))
                .foregroundStyle(isBlinking ? online : StartPalette.cream.opacity(0.7))
                .shadow(color: online.opacity(isBlinking ? 0.8 : 0), radius: 14)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isBlinking)
        }
        .onAppear { isBlinking = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantum Core online")
    }
}
