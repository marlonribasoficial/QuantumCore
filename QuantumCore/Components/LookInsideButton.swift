//
//  LookInsideButton.swift
//  QuantumCore
//
//  Botão primário "LOOK INSIDE ↓" no estilo CRT laranja:
//  gradiente vertical, bisel (via sombras internas simuladas), textura
//  scanline por cima e um glow laranja pulsante atrás.
//

import SwiftUI

struct LookInsideButton: View {
    /// Fator de escala relativo ao canvas de design (912×421).
    var scale: CGFloat = 1
    var action: () -> Void

    @State private var glowUp = false

    private var radius: CGFloat { 16 * scale }

    var body: some View {
        Button(action: action) {
            Text("LOOK INSIDE\u{00A0}↓")
                .font(.custom(AppFonts.button, size: 19 * scale))
                .tracking(0.19 * scale)
                .foregroundStyle(StartPalette.onOrange)
                .shadow(color: Color(hex: 0xFFC482, alpha: 0.45), radius: 0, x: 0, y: 1 * scale)
                .padding(.horizontal, 36 * scale)
                .padding(.top, 16 * scale)
                .padding(.bottom, 18 * scale)
                .background(buttonSurface)
        }
        .buttonStyle(PressBrightenStyle())
        .background(pulsingGlow)
        .onAppear { glowUp = true }
        .accessibilityLabel("Look inside")
        .accessibilityHint("Double tap to begin the experience")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: Superfície do botão (gradiente + bisel + scanlines + bordas)

    private var buttonSurface: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: StartPalette.accentLight, location: 0.0),
                        .init(color: StartPalette.accent,      location: 0.47),
                        .init(color: StartPalette.accentDark,  location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // Textura scanline (linhas horizontais escuras a cada 4px).
            .overlay {
                Canvas { context, size in
                    var y: CGFloat = 0
                    while y < size.height {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(.black.opacity(0.17)), lineWidth: 2)
                        y += 4
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: radius - 2, style: .continuous))
                .allowsHitTesting(false)
            }
            // Sombra interna inferior (bisel escuro embaixo).
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(hex: 0x963700, alpha: 0.55)],
                            startPoint: UnitPoint(x: 0.5, y: 0.62),
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(false)
            }
            // Brilho interno superior (bisel claro no topo).
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xFFE2C0, alpha: 0.8), .clear],
                            startPoint: .top,
                            endPoint: UnitPoint(x: 0.5, y: 0.22)
                        )
                    )
                    .allowsHitTesting(false)
            }
            // Borda laranja clara.
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(StartPalette.accentBorder, lineWidth: 2 * scale)
            }
            // Contorno escuro externo.
            .overlay {
                RoundedRectangle(cornerRadius: radius + 2 * scale, style: .continuous)
                    .stroke(Color.black.opacity(0.6), lineWidth: 2 * scale)
                    .padding(-2 * scale)
            }
            // Drop shadow + glow laranja.
            .shadow(color: .black.opacity(0.55), radius: 11 * scale, x: 0, y: 6 * scale)
            .shadow(color: StartPalette.accent.opacity(0.45), radius: 12 * scale)
    }

    // MARK: Glow pulsante atrás do botão

    private var pulsingGlow: some View {
        GeometryReader { geo in
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [StartPalette.accent.opacity(0.42), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.66
                    )
                )
                .frame(width: geo.size.width * 1.5, height: geo.size.height * 2.1)
                .blur(radius: 7 * scale)
                .opacity(glowUp ? 0.9 : 0.5)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .animation(
                    .easeInOut(duration: 1.3).repeatForever(autoreverses: true),
                    value: glowUp
                )
                .allowsHitTesting(false)
        }
    }
}

/// Estilo de botão que apenas clareia levemente ao ser pressionado
/// (equivalente iOS do hover `filter: brightness(1.08)` do protótipo).
private struct PressBrightenStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.06 : 0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
