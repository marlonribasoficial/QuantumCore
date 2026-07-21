//
//  SystemOfflineView.swift
//  QuantumCore
//
//  Animação de boot do dispositivo: "QUANTUM CORE OFFLINE" pulsando em
//  creme apagado (paleta do protótipo — offline é cinza/creme tênue,
//  como o status SYSTEM OFFLINE do chrome).
//

import SwiftUI

struct SystemOfflineView: View {

    @State private var isBlinking = false

    var body: some View {

        VStack(spacing: 8) {
            Text("QUANTUM CORE")
                .font(.custom(AppFonts.button, size: 48))
                .foregroundStyle(StartPalette.cream.opacity(isBlinking ? 0.25 : 0.7))
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: isBlinking
                )

            Text("OFFLINE")
                .font(.custom(AppFonts.button, size: 48))
                .foregroundStyle(StartPalette.cream.opacity(isBlinking ? 0.25 : 0.7))
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: isBlinking
                )
        }
        .onAppear { isBlinking = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantum Core offline")
    }
}
