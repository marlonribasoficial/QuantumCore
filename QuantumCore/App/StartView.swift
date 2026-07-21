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

    // Persistência: disponível depois para personalizar a fala do Max.
    @AppStorage("userName") private var userName = ""
    @AppStorage("userNote") private var userNote = ""

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

                    // Título + botão primário, centralizados.
                    VStack(spacing: 30 * scale) {
                        titleBlock(scale: scale)
                        LookInsideButton(scale: scale, action: start)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // ABOUT ME — canto superior direito.
                    aboutMeButton(scale: scale)
                        .frame(maxWidth: .infinity, maxHeight: .infinity,
                               alignment: .topTrailing)
                        .padding(.top, 16 * scale)
                        .padding(.trailing, 18 * scale)

                    // Modal ABOUT YOU.
                    if aboutOpen {
                        AboutYouSheet(
                            scale: scale,
                            initialName: userName,
                            initialNote: userNote,
                            onSave: { name, note in
                                userName = name
                                userNote = note
                                closeAbout()
                            },
                            onClose: closeAbout
                        )
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
        VStack(spacing: -10 * scale) {
            titleLine("QUANTUM", scale: scale)
            titleLine("CORE", scale: scale)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantum Core")
        .accessibilityAddTraits(.isHeader)
        .modifier(TitleEntrance())
    }

    private func titleLine(_ text: String, scale: CGFloat) -> some View {
        ZStack {
            // Sombra pixel (offset sólido).
            Text(text)
                .font(.custom(AppFonts.title, size: 82 * scale))
                .tracking(2.46 * scale)
                .foregroundStyle(Color.black.opacity(0.5))
                .offset(y: 3 * scale)
            Text(text)
                .font(.custom(AppFonts.title, size: 82 * scale))
                .tracking(2.46 * scale)
                .foregroundStyle(StartPalette.cream)
        }
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
