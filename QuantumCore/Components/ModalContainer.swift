//
//  ModalContainer.swift
//  QuantumCore
//
//  Container do card de feedback: card centralizado sobre a cena (sem
//  cobertura opaca), preenchendo o espaço disponível com o padding padrão
//  e mantendo a proporção 580×236 do protótipo. Gradiente radial escuro,
//  borda creme fina e raio 18.
//

import SwiftUI

struct ModalContainer<Content: View>: View {

    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = max(geometry.size.width - AppLayout.cardPadding * 2, 1)
            let availableHeight = max(geometry.size.height - AppLayout.cardPadding * 2, 1)
            let cardWidth = min(availableWidth, availableHeight * AppLayout.cardAspectRatio)
            let cardHeight = cardWidth / AppLayout.cardAspectRatio

            content()
                .padding(24)
                .frame(width: cardWidth, height: cardHeight)
                .background(
                    RadialGradient(
                        colors: [Color(hex: 0x101319), Color(hex: 0x0B0C10)],
                        center: UnitPoint(x: 0.5, y: 0.4),
                        startRadius: 0,
                        endRadius: cardWidth * 0.7
                    )
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(StartPalette.cream.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 24, y: 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
