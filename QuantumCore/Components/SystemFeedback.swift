//
//  SystemFeedback.swift
//  QuantumCore
//
//  Card de "sistema ativado" mostrado após coletar cada partícula, no formato
//  do protótipo: mini-gráfico do Quantum Core (com os sistemas já acesos),
//  "SYSTEM ACTIVATED" e o status do sistema na cor da partícula com glow.
//

import SwiftUI
import Core

struct SystemFeedback: View {

    let type: OverlayType?
    @Binding var coreEnergy: Int

    /// Sistemas já reativados (0–6), derivado da energia interna (1/6 ≈ 17%).
    private var litCount: Int {
        min(6, Int((Double(coreEnergy) / 100 * 6).rounded()))
    }

    var body: some View {
        // O conteúdo escala com o card (proporções do protótipo: badge de
        // 116px num card de 236 de altura ≈ 49%).
        GeometryReader { geometry in
            let h = geometry.size.height
            let badgeSize = h * 0.62
            let statusSize = max(30, h * 0.14)
            let activatedSize = max(11, h * 0.05)

            VStack(spacing: h * 0.06) {
                // O QuantumCore do card mostra os sistemas já coletados
                // (online = false); o recém-ativado anima a varredura de
                // "completar" e passa a brilhar.
                QuantumCoreView(litCount: litCount, sweep: .newest)
                    .frame(width: badgeSize, height: badgeSize)

                if let type {
                    VStack(spacing: 5) {
                        Text("SYSTEM ACTIVATED")
                            .font(.system(size: activatedSize, weight: .semibold))
                            .tracking(activatedSize * 0.24)
                            .foregroundStyle(StartPalette.cream.opacity(0.5))

                        Text(statusLabel(for: type))
                            .font(.custom(AppFonts.ui, size: statusSize))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(type.color)
                            .shadow(color: type.color.opacity(0.9), radius: 10)
                            .accessibilityLabel("\(type.system) activated")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// Status por sistema, igual ao protótipo.
    private func statusLabel(for type: OverlayType) -> String {
        switch type {
        case .electron: return "System Flow: ONLINE"
        case .photon:   return "Visual Systems: ENHANCED"
        case .quarks:   return "Structural Core: STABLE"
        case .gluons:   return "Core Stability: HIGH"
        case .wBoson:   return "Transformation Systems: ONLINE"
        case .zBoson:   return "System Balance: STABLE"
        }
    }
}
