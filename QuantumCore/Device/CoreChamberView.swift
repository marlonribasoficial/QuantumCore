//
//  CoreChamberView.swift
//  QuantumCore
//
//  Câmara do núcleo (aba CORE), na composição do protótipo: brilho radial,
//  piso em grade colado na base (fade em direção ao horizonte), anéis
//  concêntricos girando, colchetes de canto, uma base elíptica sob o núcleo
//  e o gráfico do Quantum Core ao centro (QuantumCoreView) — tudo apagado
//  quando offline, aceso em laranja no clímax.
//

import SwiftUI

struct CoreChamberView: View {
    /// true = todos os sistemas restaurados (clímax).
    var online: Bool

    private var accent: Color { online ? Color(hex: 0xFF7A1A) : Color(hex: 0x8A93A6) }

    // Cores da câmara (valores chGlow/chRing2 do protótipo).
    private var baseGlow: Color {
        online ? Color(hex: 0xFF7A1A, alpha: 0.16) : Color(hex: 0x788296, alpha: 0.05)
    }
    private var baseRing: Color {
        online ? Color(hex: 0xFF7A1A, alpha: 0.2) : Color(hex: 0xF2ECDE, alpha: 0.055)
    }

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height * 1.4)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    // Brilho radial de fundo.
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accent.opacity(online ? 0.16 : 0.05), .clear],
                                center: .center, startRadius: 0, endRadius: s * 0.6
                            )
                        )
                        .frame(width: s * 1.5, height: s * 1.5)

                    // Anéis concêntricos girando.
                    Circle()
                        .strokeBorder(accent.opacity(online ? 0.4 : 0.12),
                                      style: StrokeStyle(lineWidth: 1, dash: [5, 7]))
                        .frame(width: s * 0.92, height: s * 0.92)
                        .rotationEffect(.degrees(t * 8))
                    Circle()
                        .strokeBorder(accent.opacity(online ? 0.22 : 0.08), lineWidth: 1)
                        .frame(width: s * 0.78, height: s * 0.78)
                        .rotationEffect(.degrees(-t * 10))

                    // Colchetes de canto.
                    CornerBrackets(color: accent.opacity(online ? 0.55 : 0.14), lineWidth: 2)
                        .frame(width: s * 0.66, height: s * 0.66)

                    // Base elíptica ("halo" horizontal) sob o núcleo, na
                    // altura da borda inferior dos colchetes.
                    ZStack {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [baseGlow, .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: s * 0.27
                                )
                            )
                        Ellipse()
                            .stroke(baseRing, lineWidth: 1)
                    }
                    .frame(width: s * 0.77, height: s * 0.107)
                    .offset(y: s * 0.345)

                    // Quantum Core ao centro, preenchendo o quadro dos
                    // colchetes. Offline: o gráfico segmentado apagado.
                    // Online (clímax): a forma final clara — o core já
                    // passou pela transformação.
                    Group {
                        if online {
                            ConcentricCore(pale: true)
                        } else {
                            QuantumCoreView(litCount: 0, sweep: .none)
                        }
                    }
                    .frame(width: s * 0.66, height: s * 0.66)
                    .scaleEffect(1 + (online ? 0.02 * sin(t * 2.4) : 0))
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .position(center)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(online ? "Quantum Core online" : "Quantum Core offline")
    }

}

// MARK: - Colchetes de canto

private struct CornerBrackets: View {
    var color: Color
    var lineWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let len = min(w, h) * 0.12
            Path { p in
                // Superior esquerdo
                p.move(to: CGPoint(x: 0, y: len)); p.addLine(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: len, y: 0))
                // Superior direito
                p.move(to: CGPoint(x: w - len, y: 0)); p.addLine(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: w, y: len))
                // Inferior esquerdo
                p.move(to: CGPoint(x: 0, y: h - len)); p.addLine(to: CGPoint(x: 0, y: h)); p.addLine(to: CGPoint(x: len, y: h))
                // Inferior direito
                p.move(to: CGPoint(x: w - len, y: h)); p.addLine(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: w, y: h - len))
            }
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }
}

