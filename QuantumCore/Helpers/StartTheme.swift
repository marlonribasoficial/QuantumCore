//
//  StartTheme.swift
//  QuantumCore
//
//  Design tokens (cores + fontes) da tela inicial (Start Screen).
//  Valores retirados do handoff de design (README). Mantidos separados
//  de `AppColors` porque são a paleta específica desta tela.
//

import SwiftUI

// MARK: - Hex helper

extension Color {
    /// Cria uma `Color` a partir de um hex RGB (ex: `0xFF7A1A`) + alpha.
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Paleta da Start Screen

enum StartPalette {
    static let screenBase   = Color(hex: 0x0A0B0F) // fundo base da tela
    static let bgInner      = Color(hex: 0x0D0F15) // centro do gradiente radial
    static let bgOuter      = Color(hex: 0x060709) // borda do gradiente radial

    static let accent       = Color(hex: 0xFF7A1A) // laranja identidade
    static let accentLight  = Color(hex: 0xFF9B45) // topo do gradiente do botão
    static let accentBorder = Color(hex: 0xFFB066) // borda do botão
    static let accentDark   = Color(hex: 0xDF610C) // base do gradiente do botão

    static let cream        = Color(hex: 0xF2ECDE) // texto/título creme
    static let onOrange     = Color(hex: 0x1C0E02) // texto sobre laranja

    static let surface      = Color(hex: 0x07080B) // inputs
    static let cardTop      = Color(hex: 0x12151C) // topo do card do modal

    // Partículas (continuidade com o campo de partículas)
    static let photon       = Color(hex: 0xFFD84D)
    static let quark        = Color(hex: 0x8B5CF6)
    static let electron     = Color(hex: 0x00E23F)
}

// MARK: - Layout

enum AppLayout {
    /// Margem padrão dos containers de card (partícula e feedback de sistema)
    /// até as bordas da área disponível.
    static let cardPadding: CGFloat = 32
    /// Proporção largura:altura dos cards (580×236 do protótipo).
    static let cardAspectRatio: CGFloat = 580.0 / 236.0
}

// MARK: - Fontes pixel (registradas no App via registerFont)

enum AppFonts {
    /// Pixelify Sans 700 — título.
    static let title  = "PixelifySans-Bold"
    /// Press Start 2P — texto do botão primário.
    static let button = "PressStart2P-Regular"
    /// VT323 — UI, labels, inputs.
    static let ui     = "VT323-Regular"
}
