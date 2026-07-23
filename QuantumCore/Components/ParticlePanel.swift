//
//  ParticlePanel.swift
//  QuantumCore
//
//  Cartão de informação da partícula, no estilo do protótipo:
//  card escuro (gradiente radial) com borda creme fina, painel visual
//  à esquerda (modelo 3D vindo do RealityKit + scanlines) e dados
//  NAME / CHARGE / SYSTEM à direita, com o SYSTEM colorido por partícula.
//

import SwiftUI
import RealityKit
import Core

@MainActor
struct ParticlePanel: View {

    // MARK: - 3D Models Loader
    @Environment(AssetLoader.self) var loader

    let type: OverlayType

    var body: some View {
        GeometryReader { geometry in
            // Preenche o espaço disponível mantendo a proporção do card do
            // protótipo (580×236); o padding externo é do container pai.
            let cardWidth = min(geometry.size.width,
                                geometry.size.height * AppLayout.cardAspectRatio)
            let cardHeight = cardWidth / AppLayout.cardAspectRatio

            card(width: cardWidth, height: cardHeight)
                .frame(width: cardWidth, height: cardHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Card

    private func card(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            modelPane(size: height)
                .frame(width: height, height: height)

            Rectangle()
                .fill(StartPalette.cream.opacity(0.1))
                .frame(width: 1)

            infoPane
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, height * 0.14)
        }
        .background(
            RadialGradient(
                colors: [Color(hex: 0x101319), Color(hex: 0x0B0C10)],
                center: UnitPoint(x: 0.5, y: 0.4),
                startRadius: 0,
                endRadius: width * 0.7
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(StartPalette.cream.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 24, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(cardName). Charge \(cardCharge). System \(cardSystem).")
    }

    // MARK: - Painel visual (modelo 3D)

    private func modelPane(size: CGFloat) -> some View {
        RealityView { content in
            // Todas as cenas vêm do RCP (com todas as timelines).
            let model: Entity
            switch type {
            case .electron: model = loader.electron.clone(recursive: true)
            case .photon:   model = loader.photon.clone(recursive: true)
            case .quarks:   model = loader.quarksScene.clone(recursive: true)
            case .gluons:   model = loader.gluonScene.clone(recursive: true)
            case .wBoson:   model = loader.bosonWScene.clone(recursive: true)
            case .zBoson:   model = loader.bosonZScene.clone(recursive: true)
            }

            // Normaliza pelo maior lado para caber no card no mesmo tamanho de antes
            // (não-quarks ~1.2, quarks ~1.8), independente da escala da cena.
            let target: Float = (type == .quarks) ? 1.8 : 1.2
            let extents = model.visualBounds(relativeTo: nil).extents
            let maxDim = max(extents.x, extents.y, extents.z)
            if maxDim > 0 { model.scale = .one * (target / maxDim) }

            // Aciona TODAS as timelines da cena, em loop.
            playAllTimelines(from: model)

            content.add(model)
        }
        .background(
            RadialGradient(
                colors: [StartPalette.cream.opacity(0.05), .clear],
                center: .center,
                startRadius: 0,
                endRadius: size * 0.72
            )
            .background(Color.black)
        )
        .overlay(
            // Scanlines CRT sobre o painel visual.
            Canvas { context, canvasSize in
                var y: CGFloat = 0
                while y < canvasSize.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                    context.stroke(path, with: .color(.black.opacity(0.28)), lineWidth: 1)
                    y += 3
                }
            }
            .allowsHitTesting(false)
        )
        .accessibilityHidden(true)
    }

    /// Toca em loop a variante de loop de toda timeline da cena, em qualquer nível
    /// da hierarquia (cenas do RCP podem ter várias timelines, inclusive em
    /// sub-entidades referenciadas, como os quarks dentro de Quarks).
    ///
    /// Quando uma mesma entidade tem várias timelines (ex.: Eletron tem Jitter +
    /// Opacidade), elas são agrupadas — senão o segundo `playAnimation` substituiria
    /// o primeiro e só uma tocaria.
    private func playAllTimelines(from entity: Entity) {
        if let library = entity.components[AnimationLibraryComponent.self] {
            let loops = library.animations
                .filter { $0.key.hasSuffix("__auto_generated_looping") }
                .map { $0.value }

            if loops.count == 1 {
                entity.playAnimation(loops[0].repeat())
            } else if loops.count > 1 {
                if let group = try? AnimationResource.group(with: loops) {
                    entity.playAnimation(group)
                } else {
                    loops.forEach { entity.playAnimation($0.repeat()) }
                }
            }
        }
        for child in entity.children {
            playAllTimelines(from: child)
        }
    }

    // MARK: - Painel de dados

    private var infoPane: some View {
        VStack(alignment: .leading, spacing: 15) {
            field("NAME", value: cardName, color: StartPalette.cream, big: true)
            field("CHARGE", value: cardCharge, color: StartPalette.cream, big: false)
            field("SYSTEM", value: cardSystem, color: cardColor, big: false)
        }
    }

    private func field(_ label: String, value: String, color: Color, big: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .tracking(2.2)
                .foregroundStyle(StartPalette.cream.opacity(0.42))
            Text(value)
                .font(.custom(AppFonts.ui, size: big ? 46 : 30))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    // MARK: - Valores do cartão (idênticos ao protótipo)

    private var cardName: String {
        switch type {
        case .electron: return "ELECTRON"
        case .photon:   return "PHOTON"
        case .quarks:   return "QUARKS"
        case .gluons:   return "GLUON"
        case .wBoson:   return "W BOSON"
        case .zBoson:   return "Z BOSON"
        }
    }

    private var cardCharge: String {
        switch type {
        case .electron: return "-1"
        case .photon:   return "0"
        case .quarks:   return "\u{00B1}1/3"
        case .gluons:   return "0"
        case .wBoson:   return "-1"
        case .zBoson:   return "0"
        }
    }

    private var cardSystem: String {
        switch type {
        case .electron: return "SYSTEM FLOW"
        case .photon:   return "VISUAL SYSTEMS"
        case .quarks:   return "STRUCTURAL CORE"
        case .gluons:   return "CORE STABILITY"
        case .wBoson:   return "TRANSFORMATION"
        case .zBoson:   return "SYSTEM BALANCE"
        }
    }

    private var cardColor: Color {
        switch type {
        case .electron: return Color(hex: 0x00E23F)
        case .photon:   return Color(hex: 0xFFD84D)
        case .quarks:   return Color(hex: 0x8B5CF6)
        case .gluons:   return Color(hex: 0xC4CAD2)
        case .wBoson:   return Color(hex: 0x22D3EE)
        case .zBoson:   return Color(hex: 0x5B82FF)
        }
    }
}
