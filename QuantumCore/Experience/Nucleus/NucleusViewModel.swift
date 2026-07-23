import SwiftUI
import Core

@MainActor
@Observable
final class NucleusViewModel: SystemFeedbackPresenting {

    // MARK: - State
    var selectedOverlay: OverlayType?
    var interactionState: InteractionState = InteractionState()
    var interactionText: InteractionText? = .collectQuarks
    var animationPlayed: Bool = false
    var showSystemFeedback: Bool = false
    var feedbackType: OverlayType?

    // MARK: - Shared manager (vem do AtomViewModel via init)
    let dialogueManager: DialogueManager

    // MARK: - Callbacks
    var onExperienceStateChange: ((ExperienceState) -> Void)?
    var onEnergyGained: (() -> Void)?

    init(dialogueManager: DialogueManager) {
        self.dialogueManager = dialogueManager
    }

    // MARK: - State

    func syncInteractionState(from experienceState: ExperienceState) {
        interactionState = experienceState.interactionConfiguration
    }

    func presentSystemFeedback(type: OverlayType, duration: Double = 4.0, nextState: ExperienceState) {
        runSystemFeedback(type: type, duration: duration) { [weak self] in
            self?.onExperienceStateChange?(nextState)
        }
    }

    // MARK: - Dialogue Triggers

    func startQuarksDialogue() {
        withAnimation(.spring()) { selectedOverlay = .quarks }

        let sequence = DialogueSequence(
            id: "quarks_script",
            messages: Scripts.quarksScript,
            onFinish: { [weak self] in
                self?.presentSystemFeedback(type: .quarks, nextState: .quarksInteracted)
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func gluonsDiscoveredDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "gluonDiscovered_script",
            messages: Scripts.gluonDiscoveredScript,
            onFinish: { [weak self] in
                guard let self else { return }
                self.onExperienceStateChange?(.gluons)
                self.interactionText = .clickGluon
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startGluonsDialogue() {
        withAnimation(.spring()) { selectedOverlay = .gluons }

        let sequence = DialogueSequence(
            id: "gluons_script",
            messages: Scripts.gluonScript,
            onFinish: { [weak self] in
                self?.presentSystemFeedback(type: .gluons, nextState: .gluonsInteracted)
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startwBosonIntroDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "wBosonIntro_script",
            messages: Scripts.wBosonIntro,
            onFinish: { [weak self] in
                self?.onExperienceStateChange?(.quarkTransforming)
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startProtonQuarkTransformedDialogue() {
        withAnimation(.spring()) { selectedOverlay = nil }

        let sequence = DialogueSequence(
            id: "protonQuarkTransformed_script",
            messages: Scripts.protonQuarkTransformed,
            onFinish: { [weak self] in
                guard let self else { return }
                self.onExperienceStateChange?(.wBosonSpawned)
                self.interactionText = .clickParticle
            }
        )
        dialogueManager.startDialogue(sequence)
    }

    func startwBosonScriptDialogue() {
        withAnimation(.spring()) { selectedOverlay = .wBoson }

        let sequence = DialogueSequence(
            id: "wBosonScript_script",
            messages: Scripts.wBosonScript,
            onFinish: { [weak self] in
                self?.presentSystemFeedback(type: .wBoson, nextState: .leavingNucleus)
            }
        )
        dialogueManager.startDialogue(sequence)
    }
}
