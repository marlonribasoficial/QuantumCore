import SwiftUI
import Core

/// Dica de gesto exibida na base da cena (ex: "Tap the electron shell.").
/// Estilo do protótipo: pílula escura com borda laranja e o texto literal do
/// roteiro; no lugar do emoji do protótipo, um ícone de gesto nativo com halo
/// pulsante (anel que expande/contrai, como o `halo` do protótipo).
/// Reutilizada por AtomView e NucleusView.
struct InteractionOverlay: View {
    let text: InteractionText

    @State private var pulsing = false

    private var symbolName: String {
        switch text.gesture {
        case .zoom:  return "plus.magnifyingglass"
        case .point: return "hand.point.right.fill"
        case .tap:   return "hand.tap.fill"
        }
    }

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 14) {
                gestureIcon

                Text(text.rawValue)
                    .font(.custom(AppFonts.ui, size: 26))
                    .tracking(1.5)
                    .foregroundStyle(StartPalette.cream.opacity(0.92))
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(StartPalette.screenBase.opacity(0.85))
                    .overlay(Capsule().stroke(StartPalette.accent.opacity(0.55), lineWidth: 1.5))
            )
            .shadow(color: StartPalette.accent.opacity(0.35), radius: 16)
            .padding(.bottom, 40)
            .accessibilityLabel(text.rawValue)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
                AccessibilityNotification.Announcement(text.rawValue).post()
            }
        }
    }

    /// Ícone nativo + anel de halo pulsante (equivalente ao `halo` do protótipo:
    /// escala .9↔1.15 e opacidade .55↔1 em loop).
    private var gestureIcon: some View {
        ZStack {
            Circle()
                .stroke(StartPalette.accent, lineWidth: 2)
                .frame(width: 38, height: 38)
                .scaleEffect(pulsing ? 1.15 : 0.9)
                .opacity(pulsing ? 1 : 0.55)

            Image(systemName: symbolName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(StartPalette.accent)
                .offset(y: pulsing ? -2 : 2)
        }
        .frame(width: 44, height: 44)
        .accessibilityHidden(true)
    }
}

#Preview("Gesture hints") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 12) {
            InteractionOverlay(text: .tapShell)
            InteractionOverlay(text: .closerToCenter)
            InteractionOverlay(text: .clickParticle)
        }
    }
}
