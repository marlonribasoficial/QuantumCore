//
//  QuantumCoreView.swift
//  QuantumCore
//
//  O gráfico do Quantum Core, recriado ponto-a-ponto dos SVGs do design
//  (quantum-core-offline.svg / quantum-core-online.svg, viewBox 1024):
//
//  - Anel externo, 2 metades:  topo = QUARKS #8B5CF6 · base = LÉPTONS #00E23F
//  - Anel médio, 4 quartos:    ↖ GLÚON #9CA3AF/#C4CAD2 · ↗ FÓTON #FFD84D
//                              ↘ BÓSON Z #2E5BFF/#5B82FF · ↙ BÓSON W
//                                 (gradiente #FF3DBE→#22D3EE)
//  - Círculo interno #0A0B0F com aro #B98CD9 40% e núcleo branco central
//    (pequeno offline, grande quando online).
//
//  Ao acender, cada segmento anima uma varredura (o arco "se completa" do
//  início ao fim) e passa a brilhar na própria cor. O modo de varredura é
//  configurável: só o mais novo (card de feedback), todos em cascata
//  (clímax na câmara) ou nenhum.
//

import SwiftUI

struct QuantumCoreView: View {

    /// Como animar os segmentos acesos quando a view aparece.
    enum Sweep {
        /// Sem animação — estados aplicados de imediato.
        case none
        /// Já coletados aparecem acesos; só o mais recente faz a varredura.
        case newest
        /// Todos os acesos fazem a varredura em cascata (clímax).
        case all
    }

    /// Sistemas acesos (0–6), na ordem da narrativa:
    /// elétron, fóton, quarks, glúon, bóson W, bóson Z.
    var litCount: Int
    var online: Bool = false
    var sweep: Sweep = .newest

    /// Progresso de varredura de cada sistema (ordem da narrativa).
    @State private var seg: [Double] = Array(repeating: 0, count: 6)

    // MARK: Paleta (valores dos SVGs)

    private let offOuterFill = Color(hex: 0x15151B)
    private let offMidFill   = Color(hex: 0x191922)
    private let offOuterStroke = Color(hex: 0xF2ECDE, alpha: 0.12)
    private let offMidStroke   = Color(hex: 0xF2ECDE, alpha: 0.10)

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            // Espessuras dos traços na escala do viewBox 1024.
            let u = size / 1024
            let glow = size * 0.045

            ZStack {
                // ── Anel externo (raio 307.2…471.04) ──
                // Quarks (3º sistema) — metade de cima.
                segment(index: 2, from: 180, to: 360, inner: 0.6, outer: 0.92,
                        offFill: AnyShapeStyle(offOuterFill),
                        offStroke: offOuterStroke, offWidth: 2.64 * u,
                        litFill: AnyShapeStyle(Color(hex: 0x8B5CF6)),
                        litStroke: Color(hex: 0x8B5CF6),
                        litWidth: 3.3 * u, glowRadius: glow)

                // Léptons / elétron (1º sistema) — metade de baixo.
                segment(index: 0, from: 0, to: 180, inner: 0.6, outer: 0.92,
                        offFill: AnyShapeStyle(offOuterFill),
                        offStroke: offOuterStroke, offWidth: 2.64 * u,
                        litFill: AnyShapeStyle(Color(hex: 0x00E23F)),
                        litStroke: Color(hex: 0x00E23F),
                        litWidth: 3.3 * u, glowRadius: glow)

                // ── Anel médio (raio 153.6…296.96) ──
                // Glúon (4º sistema) — quarto superior esquerdo.
                segment(index: 3, from: 180, to: 270, inner: 0.3, outer: 0.58,
                        offFill: AnyShapeStyle(offMidFill),
                        offStroke: offMidStroke, offWidth: 2.2 * u,
                        litFill: AnyShapeStyle(Color(hex: 0x9CA3AF)),
                        litStroke: Color(hex: 0xC4CAD2),
                        litWidth: 2.2 * u, glowRadius: glow)

                // Fóton (2º sistema) — quarto superior direito.
                segment(index: 1, from: 270, to: 360, inner: 0.3, outer: 0.58,
                        offFill: AnyShapeStyle(offMidFill),
                        offStroke: offMidStroke, offWidth: 2.2 * u,
                        litFill: AnyShapeStyle(Color(hex: 0xFFD84D)),
                        litStroke: Color(hex: 0xFFD84D),
                        litWidth: 2.2 * u, glowRadius: glow)

                // Bóson Z (6º sistema) — quarto inferior direito.
                segment(index: 5, from: 0, to: 90, inner: 0.3, outer: 0.58,
                        offFill: AnyShapeStyle(offMidFill),
                        offStroke: offMidStroke, offWidth: 2.2 * u,
                        litFill: AnyShapeStyle(Color(hex: 0x2E5BFF)),
                        litStroke: Color(hex: 0x5B82FF),
                        litWidth: 2.2 * u, glowRadius: glow)

                // Bóson W (5º sistema) — quarto inferior esquerdo.
                segment(index: 4, from: 90, to: 180, inner: 0.3, outer: 0.58,
                        offFill: AnyShapeStyle(offMidFill),
                        offStroke: offMidStroke, offWidth: 2.2 * u,
                        // Gradiente do SVG: canto inferior-esquerdo → centro.
                        litFill: AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: 0xFF3DBE), Color(hex: 0x22D3EE)],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )),
                        litStroke: Color(hex: 0x22D3EE),
                        litWidth: 2.2 * u, glowRadius: glow)

                // ── Círculo interno (r 138.24, aro #B98CD9 40% w 8.8) ──
                Circle()
                    .fill(Color(hex: 0x0A0B0F))
                    .strokeBorder(Color(hex: 0xB98CD9, alpha: 0.4), lineWidth: 8.8 * u)
                    .frame(width: size * 0.27, height: size * 0.27)

                // ── Núcleo branco: r 40.96 offline → r 97.28 online ──
                Circle()
                    .fill(.white)
                    .frame(width: size * (online ? 0.19 : 0.08),
                           height: size * (online ? 0.19 : 0.08))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .animation(.easeInOut(duration: 0.6), value: online)
        .onAppear { applyInitial() }
        .onChange(of: litCount) { old, new in
            animateChange(from: old, to: new)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(online ? "Quantum Core online" : "Quantum Core")
    }

    // MARK: Varredura

    private func applyInitial() {
        let target = min(max(litCount, 0), 6)

        switch sweep {
        case .none:
            seg = (0..<6).map { $0 < target ? 1 : 0 }

        case .newest:
            // Já coletados acesos de imediato; o mais novo se completa.
            seg = (0..<6).map { $0 < target - 1 ? 1 : 0 }
            guard target > 0 else { return }
            withAnimation(.easeOut(duration: 0.9).delay(0.35)) {
                seg[target - 1] = 1
            }

        case .all:
            seg = Array(repeating: 0, count: 6)
            for i in 0..<target {
                withAnimation(.easeOut(duration: 0.8).delay(0.3 + Double(i) * 0.25)) {
                    seg[i] = 1
                }
            }
        }
    }

    private func animateChange(from old: Int, to new: Int) {
        let target = min(max(new, 0), 6)
        let previous = min(max(old, 0), 6)

        if target > previous {
            for i in previous..<target {
                withAnimation(.easeOut(duration: 0.9).delay(Double(i - previous) * 0.25)) {
                    seg[i] = 1
                }
            }
        } else if target < previous {
            withAnimation(.easeInOut(duration: 0.4)) {
                for i in target..<previous { seg[i] = 0 }
            }
        }
    }

    // MARK: Segmento de anel (base apagada + varredura acesa com glow)

    private func segment(
        index: Int,
        from startDeg: Double, to endDeg: Double,
        inner: CGFloat, outer: CGFloat,
        offFill: AnyShapeStyle, offStroke: Color, offWidth: CGFloat,
        litFill: AnyShapeStyle, litStroke: Color, litWidth: CGFloat,
        glowRadius: CGFloat
    ) -> some View {
        let base = RingSegment(startDeg: startDeg, endDeg: endDeg,
                               innerRatio: inner, outerRatio: outer, progress: 1)
        let lit = RingSegment(startDeg: startDeg, endDeg: endDeg,
                              innerRatio: inner, outerRatio: outer, progress: seg[index])
        return ZStack {
            base.fill(offFill)
            base.stroke(offStroke, lineWidth: offWidth)

            lit.fill(litFill)
                .overlay(lit.stroke(litStroke, lineWidth: litWidth))
                .shadow(color: litStroke.opacity(0.75 * seg[index]), radius: glowRadius)
        }
    }
}

// MARK: - Fatia de anel (ângulos: 0° = direita, 90° = baixo)

private struct RingSegment: Shape {
    /// Ângulos em graus na convenção de tela (0 = +x, crescendo em sentido
    /// horário porque o eixo y aponta para baixo).
    var startDeg: Double
    var endDeg: Double
    /// Raios como fração da metade do lado (viewBox 1024 → 512).
    var innerRatio: CGFloat
    var outerRatio: CGFloat
    /// Fração do arco desenhada (0…1) — anima a varredura de "completar".
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let clamped = min(max(progress, 0), 1)
        guard clamped > 0 else { return Path() }

        let side = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let rOuter = side / 2 * outerRatio
        let rInner = side / 2 * innerRatio
        let sweepEnd = startDeg + (endDeg - startDeg) * clamped

        var p = Path()
        p.addArc(center: center, radius: rOuter,
                 startAngle: .degrees(startDeg), endAngle: .degrees(sweepEnd),
                 clockwise: false)
        p.addArc(center: center, radius: rInner,
                 startAngle: .degrees(sweepEnd), endAngle: .degrees(startDeg),
                 clockwise: true)
        p.closeSubpath()
        return p
    }
}

#Preview("Quantum Core states") {
    HStack(spacing: 30) {
        QuantumCoreView(litCount: 0, sweep: .none)
            .frame(width: 180, height: 180)
        QuantumCoreView(litCount: 3, sweep: .newest)
            .frame(width: 180, height: 180)
        QuantumCoreView(litCount: 6, online: true, sweep: .all)
            .frame(width: 180, height: 180)
    }
    .padding(40)
    .background(Color(hex: 0x0A0B0F))
}
