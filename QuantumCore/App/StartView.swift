//
//  StartView.swift
//  QuantumCore
//
//  Tela inicial (Start Screen) da experiência. Primeiro contato:
//  título "QUANTUM / CORE", botão CRT "LOOK INSIDE ↓" que inicia a
//  narrativa do Max, e um botão "ABOUT ME" que abre o modal "ABOUT YOU".
//
//  Ao tocar em LOOK INSIDE, `started` vira true e a tela inicial dá
//  lugar à cena de narrativa (ExperienceRoot / boot do Max).
//

import SwiftUI

struct StartView: View {

    // MARK: Estado
    @State private var started = false
    @State private var aboutOpen = false

    /// Fundo fixo em GRID (preferido). Estruturado para trocar facilmente.
    private let backgroundStyle: StartBackgroundStyle = .grid

    @Environment(AssetLoader.self) private var loader

    #if os(visionOS)
    @Environment(ExperienceModel.self) private var model
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    #endif

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let scale = min(max(geo.size.width, 1) / 912,
                                max(geo.size.height, 1) / 421)

                ZStack {
                    StartBackground(style: backgroundStyle)

                    // Título + subtítulo + botões, centralizados.
                    VStack(spacing: 30 * scale) {
                        titleBlock(scale: scale)

                        VStack(spacing: 14 * scale) {
                            LookInsideButton(scale: scale, action: start)
                            aboutMeButton(scale: scale)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Modal ABOUT.
                    if aboutOpen {
                        AboutSheet(scale: scale, onClose: closeAbout)
                            .transition(.opacity)
                            .zIndex(10)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .background(StartPalette.screenBase)
            .ignoresSafeArea()
            .navigationDestination(isPresented: $started) {
                ExperienceRoot()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: aboutOpen)
        .onChange(of: started) { _, isStarted in
            if isStarted { AccessibilityNotification.ScreenChanged().post() }
        }
    }

    // MARK: Título "QUANTUM / CORE"

    private func titleBlock(scale: CGFloat) -> some View {
        VStack(spacing: 14 * scale) {
            VStack(spacing: 6 * scale) {
                titleLine("QUANTUM", scale: scale)
                titleLine("CORE", scale: scale)
            }
            subtitle(scale: scale)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantum Core. Inside the Atom.")
        .accessibilityAddTraits(.isHeader)
        .modifier(TitleEntrance())
    }

    private func titleLine(_ text: String, scale: CGFloat) -> some View {
        // Press Start 2P é bem mais largo que a fonte anterior, então o corpo é menor.
        let size = 56 * scale
        return ZStack {
            // Sombra pixel (offset sólido).
            Text(text)
                .font(.custom(AppFonts.button, size: size))
                .foregroundStyle(Color.black.opacity(0.5))
                .offset(y: 3 * scale)
            Text(text)
                .font(.custom(AppFonts.button, size: size))
                .foregroundStyle(StartPalette.cream)
        }
    }

    // MARK: Subtítulo "INSIDE THE ATOM" (San Francisco ultraLight, espaçado)

    private func subtitle(scale: CGFloat) -> some View {
        Text("INSIDE THE ATOM")
            .font(.system(size: 20 * scale, weight: .ultraLight))
            .tracking(6 * scale)
            .foregroundStyle(StartPalette.cream.opacity(0.72))
    }

    // MARK: Botão ABOUT ME

    private func aboutMeButton(scale: CGFloat) -> some View {
        Button(action: openAbout) {
            HStack(spacing: 7 * scale) {
                Image(systemName: "person.fill")
                    .font(.system(size: 12 * scale, weight: .medium))
                Text("ABOUT ME")
                    .font(.custom(AppFonts.ui, size: 17 * scale))
                    .tracking(1.0 * scale)
                    .fixedSize()
            }
            .foregroundStyle(StartPalette.cream.opacity(0.7))
            .padding(.horizontal, 13 * scale)
            .padding(.vertical, 7 * scale)
            .background(
                Capsule().fill(Color(hex: 0x0F1117, alpha: 0.6))
            )
            .overlay(
                Capsule().stroke(StartPalette.cream.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("About me")
        .accessibilityHint("Tell Max about yourself")
    }

    // MARK: Ações

    private func start() {
        started = true
        #if os(visionOS)
        Task { await openImmersiveSpace(id: "AtomSpace") }
        #endif
    }

    private func openAbout() { aboutOpen = true }
    private func closeAbout() { aboutOpen = false }
}

// MARK: - Animação de entrada do título (fade + subida de 10px, 0.7s)

private struct TitleEntrance: ViewModifier {
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) { shown = true }
            }
    }
}
