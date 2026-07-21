import SwiftUI
import Core

struct DeviceScreen: View {

    // MARK: - ViewModel
    @State private var vm = DeviceScreenViewModel()

    // MARK: - Bindings do pai
    @Binding var selectedTab: DeviceTab
    @Binding var coreEnergy: Int
    @Binding var homeOverlay: HomeOverlay

    // MARK: - Config
    let mode: DeviceMode
    var onIntroFinished: () -> Void
    var onEndingFinished: (() -> Void)? = nil

    private var isShowingDialogue: Bool { vm.dialogueManager.isShowingDialogue }

    var body: some View {
        ZStack {
            // Tela do terminal preenchendo todo o display (full-bleed).
            StartPalette.screenBase.ignoresSafeArea()
            // Scanlines esmaecem conforme a energia sobe (scanOpacity do protótipo).
            ScanlineOverlay(opacity: max(0.03, (1 - Double(coreEnergy) / 100) * 0.5))
                .ignoresSafeArea()
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.45)],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 0,
                endRadius: 700
            )
            .ignoresSafeArea()

            // Moldura + conteúdo, centralizados na tela inteira (margem simétrica).
            ZStack {
                VStack(spacing: 0) {
                    TopBar(selectedTab: $selectedTab, coreEnergy: $coreEnergy)

                    Group {
                        switch selectedTab {
                        case .home:
                            HomePanel(coreEnergy: $coreEnergy, homeOverlay: homeOverlay)
                        case .system:
                            SystemPanel(isOffline: mode != .ending)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, isShowingDialogue ? 88 : 0)
                }

                // Caixa de diálogo na base, dentro da moldura, sem waveform
                // (é uma cena com o rosto do Max).
                if isShowingDialogue {
                    VStack {
                        Spacer()
                        DialogueBox(
                            text: vm.dialogueManager.currentText,
                            isCTA: vm.dialogueManager.currentIsCTA,
                            showWaveform: false,
                            action: { vm.dialogueManager.next() }
                        )
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(StartPalette.cream.opacity(0.14), lineWidth: 1.5)
            )
            .padding(12)
        }
        // Layout na tela inteira (ignora a safe area) para a moldura ficar
        // com margens iguais nos quatro lados — centralizada de verdade.
        .ignoresSafeArea()
        .onAppear {
            vm.mode = mode
            vm.onTabChange = { selectedTab = $0 }
            vm.onHomeOverlayChange = { homeOverlay = $0 }
            vm.onIntroFinished = onIntroFinished
            vm.onEndingFinished = onEndingFinished
        }
        .task {
            if mode == .intro {
                await vm.startIntroIfNeeded()
            } else if mode == .ending {
                await vm.startEndingIfNeeded()
            }
        }
    }
}
