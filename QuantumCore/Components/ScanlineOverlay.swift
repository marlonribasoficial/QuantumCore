//
//  ScanlineOverlay.swift
//  QuantumCore
//
//  Scanlines CRT (linhas horizontais escuras de 1px a cada 3px) para dar
//  o aspecto de tela de terminal do protótipo. Puramente decorativa.
//

import SwiftUI

struct ScanlineOverlay: View {
    var opacity: Double = 0.35
    var spacing: CGFloat = 3

    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.black.opacity(opacity)), lineWidth: 1)
                y += spacing
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
