//
//  AboutSheet.swift
//  QuantumCore
//
//  Modal "ABOUT" — informações sobre a experiência e sobre o desenvolvedor.
//  Abre pelo botão ABOUT ME da Start Screen.
//

import SwiftUI

struct AboutSheet: View {
    /// Fator de escala relativo ao canvas de design (912×421).
    var scale: CGFloat = 1

    let onClose: () -> Void

    // ======================================================================
    // MARK: - Conteúdo editável — TROQUE OS TEXTOS ABAIXO
    // ======================================================================

    /// Título do modal.
    private let sheetTitle = "ABOUT"

    private let experienceHeading = "THE EXPERIENCE"
    private let experienceText = """
    An interactive journey into the heart of matter. Explore an atom in 3D, \
    meet the particles that build it — electron, photon, quarks, gluons and \
    bosons — and bring the Quantum Core online, guided by Max.
    """

    private let developerHeading = "THE DEVELOPER"
    private let developerText = """
    Marlon Ribas — Computer Science student at UNICAMP
    """

    // ======================================================================

    var body: some View {
        ZStack {
            // Overlay que escurece a tela; toque fora fecha.
            Color(hex: 0x040508, alpha: 0.72)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            card
                .frame(width: 480 * scale)
                .padding(20 * scale)
        }
    }

    // MARK: Card

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabeçalho
            HStack {
                Text(sheetTitle)
                    .font(.custom(AppFonts.ui, size: 26 * scale))
                    .tracking(1.3 * scale)
                    .foregroundStyle(StartPalette.accent)
                Spacer()
                Button(action: onClose) {
                    Text("×")
                        .font(.custom(AppFonts.ui, size: 24 * scale))
                        .foregroundStyle(StartPalette.cream.opacity(0.5))
                        .padding(.horizontal, 4 * scale)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.bottom, 18 * scale)

            section(heading: experienceHeading, body: experienceText)
                .padding(.bottom, 18 * scale)

            section(heading: developerHeading, body: developerText)
        }
        .padding(.horizontal, 24 * scale)
        .padding(.top, 22 * scale)
        .padding(.bottom, 24 * scale)
        .background(
            RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [StartPalette.cardTop, StartPalette.screenBase],
                        center: .top,
                        startRadius: 0,
                        endRadius: 480 * scale * 0.85
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                        .stroke(StartPalette.accent.opacity(0.32), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.6), radius: 30 * scale, x: 0, y: 20 * scale)
    }

    // MARK: Peças reutilizáveis

    private func section(heading: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 7 * scale) {
            Text(heading)
                .font(.custom(AppFonts.ui, size: 16 * scale))
                .tracking(1.1 * scale)
                .foregroundStyle(StartPalette.cream.opacity(0.45))
            Text(body)
                .font(.custom(AppFonts.ui, size: 20 * scale))
                .foregroundStyle(StartPalette.cream.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2 * scale)
        }
    }
}
