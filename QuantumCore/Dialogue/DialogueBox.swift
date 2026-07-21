//
//  DialogueBox.swift
//  QuantumCore
//
//  Caixa de diálogo do Max, medidas do protótipo (escala 912×421):
//  barra inferior com margens 26/22, fundo #0A0B0F, borda creme .4 de 1px,
//  raio 13, padding 13×17; waveform animada à esquerda (Max "falando"),
//  texto VT323 23 com máquina de escrever (~26 ms/caractere) + caret em
//  bloco piscando (1s, steps), botão ▶ branco de 32px ou pílula CTA laranja.
//  Um toque completa a digitação; o próximo avança.
//

import SwiftUI

struct DialogueBox: View {
    let text: String
    var isCTA: Bool = false
    /// Mostra a waveform à esquerda (Max "falando"). No protótipo, ela some
    /// nas cenas em que o rosto do Max aparece (boot / clímax).
    var showWaveform: Bool = true
    let action: () -> Void

    // Máquina de escrever
    @State private var revealStart = Date()
    @State private var forceComplete = false

    /// ~26 ms por caractere (igual ao protótipo).
    private let charsPerSecond: Double = 38

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date
            let elapsed = now.timeIntervalSince(revealStart)
            let total = text.count
            let shownCount = forceComplete ? total : min(total, max(0, Int(elapsed * charsPerSecond)))
            let isComplete = shownCount >= total
            let shown = String(text.prefix(shownCount))
            // Caret do protótipo: visível na primeira metade de cada segundo.
            let caretOn = now.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 1) < 0.5

            box(shown: shown, caretOn: caretOn, isComplete: isComplete)
        }
        .onChange(of: text) { _, _ in
            revealStart = Date()
            forceComplete = false
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 22)
    }

    private func box(shown: String, caretOn: Bool, isComplete: Bool) -> some View {
        HStack(alignment: .center, spacing: 13) {
            if showWaveform {
                DialogueWaveform()
                    .frame(width: 34, height: 20)
                    .accessibilityHidden(true)
            }

            (
                Text(shown).foregroundStyle(StartPalette.cream)
                + Text(caretOn ? "\u{258B}" : "\u{00A0}").foregroundStyle(StartPalette.cream)
            )
            .font(.custom(AppFonts.ui, size: 23))
            .lineSpacing(1.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(text)

            if isCTA {
                Button {
                    advance(isComplete: isComplete)
                } label: {
                    HStack(spacing: 8) {
                        Text("LOOK INSIDE")
                            .font(.custom(AppFonts.ui, size: 19))
                            .tracking(1.14)
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Color(hex: 0x2B1200))
                    .padding(.horizontal, 17)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(StartPalette.accent)
                    )
                    .shadow(color: StartPalette.accent.opacity(0.6), radius: 18)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .accessibilityLabel("Look inside")
                .accessibilityHint("Enter the atom")
            } else {
                Button {
                    advance(isComplete: isComplete)
                } label: {
                    ZStack {
                        Circle().fill(.white)
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(StartPalette.screenBase)
                            .offset(x: 1)
                    }
                    .frame(width: 32, height: 32)
                    .shadow(color: .white.opacity(0.65), radius: 12)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .accessibilityLabel("Next dialogue")
                .accessibilityHint("Shows the next message")
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(StartPalette.screenBase)
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .stroke(StartPalette.cream.opacity(0.4), lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .onTapGesture { advance(isComplete: isComplete) }
        .accessibilityElement(children: .contain)
    }

    private func advance(isComplete: Bool) {
        if isComplete {
            action()
        } else {
            forceComplete = true
        }
    }
}

// MARK: - Waveform animada

private struct DialogueWaveform: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let period = size.width
                let phase = CGFloat((t.truncatingRemainder(dividingBy: 1.05)) / 1.05) * period
                let mid = size.height / 2
                let amp = size.height * 0.42

                // Padrão de pico repetido, deslizando para a esquerda.
                func wave(startX: CGFloat) -> Path {
                    var p = Path()
                    let step = period / 7
                    let ys: [CGFloat] = [0, -0.6, 0.9, -0.3, 0.6, -0.9, 0]
                    p.move(to: CGPoint(x: startX, y: mid))
                    for i in 0..<ys.count {
                        p.addLine(to: CGPoint(x: startX + step * CGFloat(i),
                                              y: mid + ys[i] * amp))
                    }
                    return p
                }

                for k in -1...1 {
                    let startX = CGFloat(k) * period - phase
                    context.stroke(
                        wave(startX: startX),
                        with: .color(StartPalette.accent),
                        style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
                    )
                }
            }
            .drawingGroup()
        }
    }
}

#Preview("DialogueBox") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            DialogueBox(text: "This is the electron shell, one of the two regions inside an atom.") {}
        }
    }
}
