//
//  TopBar.swift
//  QuantumCore
//
//  Chrome do dispositivo do Max: abas MAX / CORE à esquerda (encostadas na
//  borda inferior da barra) e barras de sinal à direita — acesas quando o
//  núcleo está cheio.
//

import SwiftUI
import Core

struct TopBar: View {
    @Binding var selectedTab: DeviceTab
    @Binding var coreEnergy: Int

    private var online: Bool { coreEnergy >= 100 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            TabButton(title: "MAX", selected: selectedTab == .home) {
                selectedTab = .home
            }
            .padding(.leading, 12)
            TabButton(title: "CORE", selected: selectedTab == .system) {
                selectedTab = .system
            }

            Spacer(minLength: 12)

            signalBars
                .padding(.bottom, 12)
                .padding(.trailing, 12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 9)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(StartPalette.cream.opacity(0.1))
                .frame(height: 1)
        }
        .background(StartPalette.screenBase)
    }

    private var signalBars: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach([8, 13, 18], id: \.self) { height in
                RoundedRectangle(cornerRadius: 1)
                    .fill(online ? Color.white : StartPalette.cream.opacity(0.13))
                    .frame(width: 5, height: CGFloat(height))
                    .shadow(color: .white.opacity(online ? 0.9 : 0), radius: 4)
            }
        }
        .accessibilityHidden(true)
    }
}
