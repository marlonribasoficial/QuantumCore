//
//  StartBackground.swift
//  QuantumCore
//
//  Fundo animado da Start Screen. Duas variantes previstas no design
//  (GRID e FIELD); só GRID está implementada — que é a preferida.
//  O `switch` já existe para tornar trivial ligar a variante FIELD depois.
//
//  Tudo é desenhado (Canvas / Shape / gradients) — sem imagens.
//

import SwiftUI

/// Variantes de fundo da tela inicial. FIELD era só ferramenta de protótipo;
/// mantida aqui como ponto de extensão para futuro toggle.
enum StartBackgroundStyle {
    case grid
    case field
}

struct StartBackground: View {
    var style: StartBackgroundStyle = .grid

    var body: some View {
        switch style {
        case .grid:
            StartGridBackground()
        case .field:
            // Ainda não implementada — cai no GRID para não quebrar.
            StartGridBackground()
        }
    }
}

// MARK: - Variante GRID (terminal / CRT)

private struct StartGridBackground: View {

    // Fração da altura onde fica a linha do horizonte (bottom:39% → 61% do topo).
    private let horizonFraction: CGFloat = 0.61

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let scale = min(size.width / 912, size.height / 421)
            let horizonY = size.height * horizonFraction

            ZStack {
                // Fundo base + gradiente radial.
                StartPalette.screenBase
                RadialGradient(
                    colors: [StartPalette.bgInner, StartPalette.bgOuter],
                    center: UnitPoint(x: 0.5, y: 0.42),
                    startRadius: 0,
                    endRadius: max(size.width, size.height) * 0.74
                )

                // Piso em grade com perspectiva, rolando para dar sensação de avanço.
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    Canvas { context, canvasSize in
                        drawPerspectiveGrid(
                            context: &context,
                            size: canvasSize,
                            horizonY: horizonY,
                            scale: scale,
                            time: t
                        )
                    }
                    .mask(
                        // Fade do horizonte para cima (as linhas somem perto do horizonte).
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: horizonFraction - 0.02),
                                .init(color: .black, location: 0.92)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.62)
                }

                // Brilho de horizonte (elipse radial laranja) + linha fina do horizonte.
                Ellipse()
                    .fill(StartPalette.accent)
                    .frame(width: size.width * 0.72, height: 150 * scale)
                    .position(x: size.width * 0.5, y: horizonY - 30 * scale)
                    .blur(radius: 42 * scale)
                    .opacity(0.20)

                LinearGradient(
                    colors: [.clear, StartPalette.accent.opacity(0.55), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .position(x: size.width * 0.5, y: horizonY)

                // Scanlines CRT sobre toda a tela.
                Canvas { context, canvasSize in
                    drawScanlines(context: &context, size: canvasSize)
                }
                .allowsHitTesting(false)

                // 3 orbes tênues (continuidade com a variante FIELD).
                FloatingOrbs(size: size, scale: scale)
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: Grade em perspectiva

    private func drawPerspectiveGrid(
        context: inout GraphicsContext,
        size: CGSize,
        horizonY: CGFloat,
        scale: CGFloat,
        time: Double
    ) {
        let width = size.width
        let bottomY = size.height * 1.15          // estende abaixo da tela p/ loop sem "pop"
        let floorHeight = bottomY - horizonY
        let centerX = width * 0.5
        let horizonDistance: CGFloat = 5.5         // controla a compressão em profundidade
        let lineWidth = max(0.6, scale)

        let period = 2.8
        let phase = CGFloat((time.truncatingRemainder(dividingBy: period)) / period) // 0..1

        // Projeta a linha de profundidade `z` (0 = perto) para y na tela.
        func rowY(_ z: CGFloat) -> CGFloat {
            horizonY + floorHeight * horizonDistance / (horizonDistance + z)
        }

        // Linhas horizontais (profundidade constante), rolando para baixo (avanço).
        let rowCount = 26
        for i in 0...rowCount {
            let z = CGFloat(i) + (1 - phase)      // loop contínuo e sem emenda
            let y = rowY(z)
            guard y >= horizonY - 1, y <= size.height + 2 else { continue }

            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))

            // Perto → mais opaco; longe (perto do horizonte) → some.
            let alpha = 0.30 * (1 - min(1, z / CGFloat(rowCount)))
            context.stroke(
                path,
                with: .color(StartPalette.accent.opacity(alpha)),
                lineWidth: lineWidth
            )
        }

        // Linhas verticais (correm na profundidade) convergindo ao ponto de fuga.
        let vanishingPoint = CGPoint(x: centerX, y: horizonY)
        let nearSpacing = 44 * scale * 1.6
        let maxSpan = width * 1.4
        var offset: CGFloat = 0
        while offset <= maxSpan {
            let signs: [CGFloat] = offset == 0 ? [0] : [-1, 1]
            for sign in signs {
                let nearX = centerX + sign * offset
                var path = Path()
                path.move(to: CGPoint(x: nearX, y: bottomY))
                path.addLine(to: vanishingPoint)
                context.stroke(
                    path,
                    with: .color(StartPalette.accent.opacity(0.22)),
                    lineWidth: lineWidth
                )
            }
            offset += nearSpacing
        }
    }

    // MARK: Scanlines CRT (1px escuro a cada 3px)

    private func drawScanlines(context: inout GraphicsContext, size: CGSize) {
        var y: CGFloat = 0
        while y < size.height {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(.black.opacity(0.30)), lineWidth: 1)
            y += 3
        }
    }
}

// MARK: - Orbes flutuantes

private struct FloatingOrbs: View {
    let size: CGSize
    let scale: CGFloat

    // (posição relativa x, y, diâmetro base, cor, período de deriva)
    private struct Orb {
        let x: CGFloat
        let y: CGFloat
        let diameter: CGFloat
        let color: Color
        let period: Double
    }

    private var orbs: [Orb] {
        [
            Orb(x: 0.18, y: 0.26, diameter: 12, color: StartPalette.photon,   period: 15),
            Orb(x: 0.80, y: 0.32, diameter: 9,  color: StartPalette.quark,    period: 18),
            Orb(x: 0.72, y: 0.18, diameter: 7,  color: StartPalette.electron, period: 16)
        ]
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(Array(orbs.enumerated()), id: \.offset) { _, orb in
                    let drift = sin(t / orb.period * 2 * .pi)
                    let d = orb.diameter * scale
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, orb.color],
                                center: UnitPoint(x: 0.38, y: 0.32),
                                startRadius: 0,
                                endRadius: d * 0.7
                            )
                        )
                        .frame(width: d, height: d)
                        .shadow(color: orb.color.opacity(0.6), radius: d * 0.8)
                        .position(
                            x: size.width * orb.x,
                            y: size.height * orb.y + drift * 10 * scale
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
