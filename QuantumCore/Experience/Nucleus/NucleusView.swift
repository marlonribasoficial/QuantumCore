import SwiftUI
import Core
import RealityKit

@MainActor
struct NucleusView: View {

    // MARK: - 3D Models Loader
    @Environment(AssetLoader.self) var loader

    // MARK: - External State (vem do AtomViewModel via AtomView)
    @Binding var experienceState: ExperienceState
    var dialogueManager: DialogueManager

    // MARK: - ViewModel
    @State private var vm: NucleusViewModel

    // MARK: - Entities (ficam na View — objetos de referência do RealityKit)
    @State private var protonQuarks: Entity?
    @State private var quarks: Entity?
    @State private var gluons: Entity?
    @State private var upTransforming: Entity?
    @State private var wBoson: Entity?

    // MARK: - Bindings do pai
    @Binding var coreEnergy: Int

    init(
        experienceState: Binding<ExperienceState>,
        dialogueManager: DialogueManager,
        coreEnergy: Binding<Int>
    ) {
        _experienceState = experienceState
        self.dialogueManager = dialogueManager
        _coreEnergy = coreEnergy
        _vm = State(wrappedValue: NucleusViewModel(dialogueManager: dialogueManager))
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            RealityView { content in
                let loaded = loader.protonQuarks.clone(recursive: true)

                loaded.scale = .init(repeating: 0.16)

                content.add(loaded)
                protonQuarks = loaded

                quarks = loaded.findEntity(named: "Quarks")
                gluons = loaded.findEntity(named: "Gluons")
                wBoson = loaded.findEntity(named: "BosonW")
                upTransforming = loaded.findEntity(named: "Up_transforming")

                vm.syncInteractionState(from: experienceState)
                applyInteractionState()
            }
            .gesture(spatialTapGesture)
            .simultaneousGesture(dragGesture)
            #if !os(visionOS)
            .ignoresSafeArea()
            .background(AppColors.proton)
            #endif

            if let text = vm.interactionText {
                InteractionOverlay(text: text)
            }

            // No visionOS o diálogo é renderizado como ornament no AtomView pai
            #if !os(visionOS)
            if dialogueManager.isShowingDialogue {
                DialogueBubbleView(manager: dialogueManager, type: vm.selectedOverlay)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .bottom)
                        )
                    )
            }
            #endif

            if vm.showSystemFeedback {
                ModalContainer {
                    SystemFeedback(type: vm.feedbackType, coreEnergy: $coreEnergy)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .opacity
                    )
                )
            }
        }
        .onAppear {
            vm.onEnergyGained = { coreEnergy += EnergyReward.particleInteraction }
            vm.onExperienceStateChange = { newState in experienceState = newState }
        }
        .onChange(of: experienceState) { _, newState in
            vm.syncInteractionState(from: newState)
            applyInteractionState()
            handleStateChange(newState)
        }
    }
}

// MARK: - Gestures
private extension NucleusView {

    var spatialTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                handleTapInteraction(at: value)
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                rotate(translation: value.translation)
            }
    }

    func handleTapInteraction(at value: EntityTargetValue<SpatialTapGesture.Value>) {
        let tappedEntity = value.entity

        if let quarks, tappedEntity.isDescendant(of: quarks) {
            if experienceState == .insideProton {
                vm.interactionText = nil
                vm.onExperienceStateChange?(.quarks)
                vm.startQuarksDialogue()
            }
            return
        }

        if let gluons, tappedEntity.isDescendant(of: gluons) {
            vm.interactionText = nil
            vm.startGluonsDialogue()
            return
        }

        if let wBoson, tappedEntity.isDescendant(of: wBoson) {
            vm.interactionText = nil
            vm.startwBosonScriptDialogue()
            return
        }
    }

    func rotate(translation: CGSize) {
        guard let protonQuarks else { return }
        let dx = Float(translation.width) * 0.0005
        let dy = Float(translation.height) * 0.0005
        let qx = simd_quatf(angle: dy, axis: [1,0,0])
        let qy = simd_quatf(angle: dx, axis: [0,1,0])
        protonQuarks.transform.rotation = qy * qx * protonQuarks.transform.rotation
    }
}

// MARK: - Experience State Handler
private extension NucleusView {

    func handleStateChange(_ newState: ExperienceState) {
        switch newState {

        case .quarksInteracted:
            Task {
                try? await Task.sleep(for: .seconds(1.0))
                vm.gluonsDiscoveredDialogue()
            }

        case .gluonsInteracted:
            Task {
                try? await Task.sleep(for: .seconds(1.0))
                vm.startwBosonIntroDialogue()
            }

        case .quarkTransforming:
            Task {
                triggerTransformation()
                try? await Task.sleep(for: .seconds(3.0))
                vm.startProtonQuarkTransformedDialogue()
            }

        default:
            break
        }
    }

    func applyInteractionState() {
        if let quarks { quarks.setInteractivity(enabled: vm.interactionState.canInteractWithQuarks) }
        if let gluons { gluons.setInteractivity(enabled: vm.interactionState.canInteractWithGluons) }
        if let wBoson { wBoson.setInteractivity(enabled: vm.interactionState.canInteractWithWBoson) }
    }
}

// MARK: - Entity Triggers
private extension NucleusView {

    func triggerTransformation() {
        guard !vm.animationPlayed else { return }
        vm.animationPlayed = true

        if let quarks, let animation = quarks.availableAnimations.first {
            quarks.playAnimation(animation)
        }

        Task {
            try? await Task.sleep(for: .seconds(2.0))
            if let upTransforming { changeParticleColor(entity: upTransforming) }
        }

        if let wBoson, let animation = wBoson.availableAnimations.first {
            wBoson.playAnimation(animation)
        }
    }

    func changeParticleColor(entity: Entity) {
        guard let modelEntity = entity as? ModelEntity ??
                entity.findEntity(named: "") as? ModelEntity ??
                entity.children.first(where: { $0 is ModelEntity }) as? ModelEntity else { return }

        var material = PhysicallyBasedMaterial()
        #if os(iOS)
        material.baseColor = .init(tint: UIColor(red: 0.7, green: 0.3, blue: 0.8, alpha: 1.0))
        #else
        material.baseColor = .init(tint: .init(red: 0.7, green: 0.3, blue: 0.8, alpha: 1.0))
        #endif
        material.roughness = 0.5
        material.metallic = 0.1
        modelEntity.model?.materials = [material]
    }
}
