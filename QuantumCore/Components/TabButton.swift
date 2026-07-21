//
//  TabButton.swift
//  QuantumCore
//
//  Aba estilo "pasta de terminal" (cantos superiores arredondados,
//  sem borda inferior) usada no chrome do dispositivo (MAX / CORE).
//

import SwiftUI

struct TabButton: View {
    let title: String
    let selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom(AppFonts.ui, size: 18))
                .tracking(1.1)
                .foregroundStyle(selected ? StartPalette.accent : StartPalette.cream.opacity(0.4))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 9,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 9,
                        style: .continuous
                    )
                    .fill(selected ? Color(hex: 0x12161C) : .clear)
                )
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 9,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 9,
                        style: .continuous
                    )
                    .stroke(selected ? StartPalette.accent.opacity(0.42) : StartPalette.cream.opacity(0.14),
                            lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

#Preview("TabButton states") {
    HStack(spacing: 8) {
        TabButton(title: "MAX", selected: true) {}
        TabButton(title: "CORE", selected: false) {}
    }
    .padding()
    .background(Color.black)
}
