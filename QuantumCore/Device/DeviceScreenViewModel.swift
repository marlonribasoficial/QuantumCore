import SwiftUI
import Core

@MainActor
@Observable
final class DeviceScreenViewModel {

    // MARK: - State
    var introPhase: IntroPhase = .idle
    var introStarted = false
    var endingStarted = false

    // MARK: - Managers
    let dialogueManager = DialogueManager()

    // MARK: - Config
    var mode: DeviceMode = .intro

    // MARK: - Callbacks
    var onTabChange: ((DeviceTab) -> Void)?
    var onHomeOverlayChange: ((HomeOverlay) -> Void)?
    var onIntroFinished: (() -> Void)?
    var onEndingFinished: (() -> Void)?

    // MARK: - Intro Flow

    func startIntroIfNeeded() async {
        guard !introStarted else { return }
        introStarted = true
        await startIntroFlow()
    }

    func startEndingIfNeeded() async {
        guard !endingStarted else { return }
        endingStarted = true
        await startEndingFlow()
    }

    func startIntroFlow() async {
        try? await Task.sleep(for: .seconds(4.0))

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.6)) {
                onHomeOverlayChange?(.robot)
            }
        }

        try? await Task.sleep(for: .milliseconds(500))

        introPhase = .intro
        startDialogue(Scripts.introScript)
    }

    func startEndingFlow() async {
        // 1) Transformação do Quantum Core: colorido → laranja → claro
        //    (~5s de sequência + 1.2s admirando a forma final).
        await MainActor.run {
            onHomeOverlayChange?(.coreTransformation)
        }

        try? await Task.sleep(for: .seconds(6.2))

        // 2) "QUANTUM CORE ONLINE".
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.6)) {
                onHomeOverlayChange?(.animationEnding)
            }
        }

        try? await Task.sleep(for: .seconds(4.0))

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.6)) {
                onHomeOverlayChange?(.robot)
            }
        }

        try? await Task.sleep(for: .milliseconds(500))

        introPhase = .finished
        startDialogue(Scripts.endingScript)
    }

    // MARK: - Dialogue

    func startDialogue(_ messages: [String], cta: Bool = false) {
        let sequence = DialogueSequence(
            id: UUID().uuidString,
            messages: messages,
            cta: cta
        ) { [weak self] in
            self?.handleNextPhase()
        }
        dialogueManager.startDialogue(sequence)
    }

    func handleNextPhase() {
        if mode == .ending {
            if introPhase == .finished {
                introPhase = .callToAction
                withAnimation(.easeInOut) { onTabChange?(.system) }
                startDialogue(Scripts.endingScript2)
                return
            } else if introPhase == .callToAction {
                introPhase = .atom
                withAnimation(.easeInOut) {
                    onTabChange?(.home)
                    onHomeOverlayChange?(.robot)
                }
                startDialogue(Scripts.endingScript3)
                return
            } else if introPhase == .atom {
                onEndingFinished?()
                return
            }
        }

        switch introPhase {
        case .intro:
            introPhase = .whatHappened
            startDialogue(Scripts.whatHappenedScript)

        case .whatHappened:
            withAnimation(.easeInOut) { onTabChange?(.system) }
            introPhase = .systems
            startDialogue(Scripts.systemsScript)

        case .systems:
            withAnimation(.easeInOut) { onTabChange?(.home) }
            introPhase = .atom
            startDialogue(Scripts.atomScript)

        case .atom:
            introPhase = .callToAction
            startDialogue(Scripts.callToActionScript, cta: true)

        case .callToAction:
            introPhase = .finished
            onIntroFinished?()

        default:
            break
        }
    }
}
