import SwiftUI
import Core

@MainActor
@Observable
final class AtomViewModel: SystemFeedbackPresenting {

    // MARK: - State
    var interactionState = InteractionState()
    var wasElectronSpawned = false
    var wasParticlesInteracted = false
    var experienceState: ExperienceState = .intro
    var selectedOverlay: OverlayType?
    var interactionText: InteractionText? = nil
    var electronPos: SIMD3<Float> = .zero
    var currentScale: Float = 1.0
    var maxScale: Float = 20.0
    var showSystemFeedback = false
    var feedbackType: OverlayType?
    var scaleBeforeNucleus: Float = 400.0

    // MARK: - Constants
    let minScale: Float = 1.0

    // MARK: - Managers
    let dialogueManager = DialogueManager()

    // MARK: - Callbacks (para valores que vivem no pai como @Binding)
    var onEnergyGained: (() -> Void)?
    var onZBosonFinished: (() -> Void)?

    // MARK: - State Transitions

    func checkScaleThresholds() {
        if currentScale > 3.0, experienceState == .exploring {
            guard !dialogueManager.isShowingDialogue else { return }
            setExperienceState(.shellIntro)
            interactionText = nil
            startShellDialogue()
            return
        }
        if currentScale >= 500, experienceState == .nucleus {
            setExperienceState(.closeToNucleus)
            interactionText = nil
            lookingToNucleusDialogue()
        }
    }

    func setExperienceState(_ state: ExperienceState) {
        experienceState = state
        interactionState = state.interactionConfiguration
    }

    func presentSystemFeedback(
        type: OverlayType,
        duration: Double = 4.0,
        nextState: ExperienceState,
        onComplete: (() -> Void)? = nil
    ) {
        runSystemFeedback(type: type, duration: duration) { [weak self] in
            guard let self else { return }
            self.setExperienceState(nextState)

            Task {
                try? await Task.sleep(for: .seconds(1.0))
                onComplete?()
            }
        }
    }

    // MARK: - Dialogue Triggers

    func lookingToAtomScriptDialogue() {
        let sequence = DialogueSequence(
            id: "lookingToAtomScript_script",
            messages: Scripts.lookingToAtomScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.experienceState = .exploring
                self.interactionState = ExperienceState.exploring.interactionConfiguration
                self.interactionText = .zoomIn
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startShellDialogue() {
        let sequence = DialogueSequence(
            id: "shellIntro_script",
            messages: Scripts.shellIntroScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.experienceState = .shellDiscovered
                self.interactionState = ExperienceState.shellDiscovered.interactionConfiguration
                self.interactionText = .tapShell
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    /// Descoberta: toca quando a pessoa toca na eletrosfera e o elétron spawna
    /// (ainda sem card). Ao terminar, mostra a dica de coletar o elétron.
    func electronSpawnedDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "electronSpawned_script",
            messages: Scripts.electronScript,
            onFinish: { [weak self] in
                self?.interactionText = .collectElectron
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    /// Card: toca quando a pessoa toca no elétron — sobe o card e o texto detalhado.
    func startElectronDialogue() {
        withAnimation(.spring()) { selectedOverlay = .electron }

        let sequence = DialogueSequence(
            id: "electron_script",
            messages: Scripts.electronCard,
            onFinish: { [weak self] in
                self?.presentSystemFeedback(type: .electron, nextState: .electronInteracted)
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func photonFound() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "photonFound_script",
            messages: Scripts.photonFoundScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.experienceState = .photonSpawned
                self.interactionState = ExperienceState.photonSpawned.interactionConfiguration
                self.interactionText = .collectPhoton
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startPhotonDialogue() {
        withAnimation(.spring()) { selectedOverlay = .photon }

        let sequence = DialogueSequence(
            id: "photon_script",
            messages: Scripts.photonCard,
            onFinish: { [weak self] in
                self?.presentSystemFeedback(type: .photon, nextState: .photonInteracted)
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func goingToNucleusDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "goingToNucleus_script",
            messages: Scripts.goingToNucleusScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.experienceState = .nucleus
                self.interactionState = ExperienceState.nucleus.interactionConfiguration
                self.interactionText = .closerToCenter
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func lookingToNucleusDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "lookingToNucleus_script",
            messages: Scripts.lookingToNucleusScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.experienceState = .zoomingIntoNucleus
                self.interactionState = ExperienceState.zoomingIntoNucleus.interactionConfiguration
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func backToShellDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "backToShell_script",
            messages: Scripts.backToShellScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.experienceState = .backToShell
                self.interactionState = ExperienceState.backToShell.interactionConfiguration
                self.interactionText = .tapShell
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startZBosonDialogue() {
        withAnimation(.spring()) { selectedOverlay = .zBoson }

        let sequence = DialogueSequence(
            id: "zBoson_script",
            messages: Scripts.zBosonCard,
            onFinish: { [weak self] in
                self?.presentSystemFeedback(
                    type: .zBoson,
                    nextState: .zBosonInteracted,
                    onComplete: { [weak self] in self?.onZBosonFinished?() }
                )
            }
        )
        dialogueManager.startDialogue(sequence)
    }
}
