//
//  ConcentricCore.swift
//  QuantumCore
//
//  As duas formas "finais" do Quantum Core, com valores exatos dos SVGs
//  "Quantum Core Final (1)" (laranja) e "(2)" (clara), viewBox 1024.
//  A forma laranja usa os MESMOS raios do QuantumCoreView (anéis 0.6–0.92 e
//  0.3–0.58), então a virada colorido→laranja alinha perfeitamente; daqui
//  para a forma clara cada camada anima raio, espessura, cor e opacidade.
//
//  Usada pela CoreTransformationView (morph do clímax) e pela câmara do
//  CORE quando o sistema está online (forma final, pale = true).
//

import SwiftUI

struct ConcentricCore: View {
    var pale: Bool

    private let accent = Color(hex: 0xFF7A1A)
    private let accentLight = Color(hex: 0xFF9B45)

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let u = s / 1024

            ZStack {
                // Halo suave de fundo (só na forma clara): r 384 @ 16%.
                Circle()
                    .fill(accent)
                    .frame(width: s * 0.75, height: s * 0.75)
                    .opacity(pale ? 0.16 : 0)

                // Anel externo #FF7A1A:
                // sólido 0.6–0.92 → fino ⌀0.84 (w 15.36) @ 38%.
                Ring(outerFrac: pale ? 0.855 : 0.92,
                     innerFrac: pale ? 0.825 : 0.60)
                    .fill(accent, style: FillStyle(eoFill: true))
                    .opacity(pale ? 0.38 : 1)

                // Anel médio #FF9B45:
                // sólido 0.3–0.58 → ⌀0.6 (w 25.6) @ 70%.
                Ring(outerFrac: pale ? 0.625 : 0.58,
                     innerFrac: pale ? 0.575 : 0.30)
                    .fill(accentLight, style: FillStyle(eoFill: true))
                    .opacity(pale ? 0.7 : 1)

                // Núcleo: disco preto ⌀0.30 → disco laranja ⌀0.38.
                Circle()
                    .fill(pale ? accent : Color(hex: 0x0A0B0F))
                    .frame(width: s * (pale ? 0.38 : 0.30),
                           height: s * (pale ? 0.38 : 0.30))

                // Aro do núcleo #DF610C (w 20.48) — some na forma clara.
                Circle()
                    .stroke(Color(hex: 0xDF610C), lineWidth: 20.48 * u)
                    .frame(width: s * 0.30, height: s * 0.30)
                    .opacity(pale ? 0 : 1)

                // Ponto central #FFCFA0: ⌀0.14 → ⌀0.17.
                Circle()
                    .fill(Color(hex: 0xFFCFA0))
                    .frame(width: s * (pale ? 0.17 : 0.14),
                           height: s * (pale ? 0.17 : 0.14))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantum Core")
    }
}

/// Anel (coroa circular) com raios animáveis, preenchido via even-odd.
private struct Ring: Shape {
    /// Diâmetros externo/interno como fração do menor lado.
    var outerFrac: CGFloat
    var innerFrac: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(outerFrac, innerFrac) }
        set {
            outerFrac = newValue.first
            innerFrac = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)

        func circleRect(_ frac: CGFloat) -> CGRect {
            let d = s * frac
            return CGRect(x: center.x - d / 2, y: center.y - d / 2,
                          width: d, height: d)
        }

        var p = Path()
        p.addEllipse(in: circleRect(outerFrac))
        p.addEllipse(in: circleRect(innerFrac))
        return p
    }
}

#Preview("Formas finais") {
    HStack(spacing: 30) {
        ConcentricCore(pale: false)
            .frame(width: 200, height: 200)
        ConcentricCore(pale: true)
            .frame(width: 200, height: 200)
    }
    .padding(40)
    .background(Color(hex: 0x0A0B0F))
}
