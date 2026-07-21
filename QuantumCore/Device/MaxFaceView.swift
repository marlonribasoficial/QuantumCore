//
//  MaxFaceView.swift
//  QuantumCore
//
//  Rosto do Max em matriz de pontos laranja (recriação do protótipo):
//  dois olhos formados por pontos que cintilam e uma "boca" em onda que
//  abre e fecha. Escuro/tênue quando offline, aceso e com glow quando
//  o sistema está online (clímax).
//

import SwiftUI

struct MaxFaceView: View {
    /// true = sistema online (clímax): laranja forte + glow.
    var lit: Bool = false

    // Pontos dos olhos no espaço 300×120 do protótipo: (x, y, raio, período).
    private let eyeDots: [(x: CGFloat, y: CGFloat, r: CGFloat, period: Double)] = [
        (98, 42, 3.4, 2.4), (112, 36, 4, 2.9), (126, 42, 3.4, 2.2),
        (112, 50, 5, 2.5), (105, 44, 2.6, 3.1), (119, 44, 2.6, 2.7),
        (174, 42, 3.4, 2.6), (188, 36, 4, 3.0), (202, 42, 3.4, 2.3),
        (188, 50, 5, 2.8), (181, 44, 2.6, 2.4), (195, 44, 2.6, 3.2)
    ]

    private let cornerDots: [(x: CGFloat, y: CGFloat, r: CGFloat, period: Double)] = [
        (56, 28, 2, 3.4), (244, 32, 2, 3.7), (72, 94, 1.6, 3.0), (228, 94, 1.6, 3.9)
    ]

    private let mouthPoints: [(x: CGFloat, y: CGFloat)] = [
        (104, 84), (116, 84), (126, 72), (138, 96), (150, 78),
        (162, 96), (174, 72), (184, 84), (196, 84)
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let scale = min(size.width / 300, size.height / 120)
                let ox = (size.width - 300 * scale) / 2
                let oy = (size.height - 120 * scale) / 2
                func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                    CGPoint(x: ox + x * scale, y: oy + y * scale)
                }

                let baseAlpha = lit ? 1.0 : 0.42
                let orange = Color(hex: 0xFF7A1A)

                // Olhos — pontos cintilantes.
                for dot in eyeDots {
                    let twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin(t / dot.period * 2 * .pi))
                    let center = point(dot.x, dot.y)
                    let radius = dot.r * scale
                    let rect = CGRect(x: center.x - radius, y: center.y - radius,
                                      width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect),
                                 with: .color(orange.opacity(baseAlpha * twinkle)))
                }

                // Pontos tênues nos cantos.
                for dot in cornerDots {
                    let twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin(t / dot.period * 2 * .pi))
                    let center = point(dot.x, dot.y)
                    let radius = dot.r * scale
                    let rect = CGRect(x: center.x - radius, y: center.y - radius,
                                      width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: rect),
                                 with: .color(orange.opacity(baseAlpha * 0.5 * twinkle)))
                }

                // Boca — onda que abre e fecha (scaleY em torno de y=84).
                let mouthScale = 0.4 + 0.6 * (0.5 + 0.5 * sin(t / 2.6 * 2 * .pi))
                var mouth = Path()
                for (i, p) in mouthPoints.enumerated() {
                    let y = 84 + (p.y - 84) * mouthScale
                    let pt = point(p.x, y)
                    if i == 0 { mouth.move(to: pt) } else { mouth.addLine(to: pt) }
                }
                context.stroke(mouth,
                               with: .color(orange.opacity(baseAlpha)),
                               style: StrokeStyle(lineWidth: 2.8 * scale, lineCap: .round, lineJoin: .round))
            }
            .shadow(color: Color(hex: 0xFF7A1A).opacity(lit ? 0.85 : 0.3),
                    radius: lit ? 10 : 4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lit ? "Max, online" : "Max")
    }
}

#Preview("Max face") {
    HStack(spacing: 40) {
        MaxFaceView(lit: false)
        MaxFaceView(lit: true)
    }
    .frame(height: 160)
    .padding(40)
    .background(Color.black)
}
