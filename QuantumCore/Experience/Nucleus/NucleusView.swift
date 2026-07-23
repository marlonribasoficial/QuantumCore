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
    // Cena Nucleon (RCP): quarks são 3 entidades de topo (QuarkDown, QuarkUp,
    // QuarkDownToUp), glúons em `gluon_conexoes`, e o bóson W fica aninhado dentro
    // do QuarkDownToUp (é ele que medeia a transformação down→up).
    @State private var nucleon: Entity?
    @State private var quarkEntities: [Entity] = []
    @State private var gluons: Entity?
    @State private var downToUp: Entity?
    @State private var wBoson: Entity?

    // Entidades que só existem a partir da transformação (bóson W + o quark up que
    // ele revela). Ficam desativadas no idle: o bóson W tem halos transparentes/
    // emissivos que causam overdraw pesado no simulador (render por software).
    @State private var transformOnlyEntities: [Entity] = []

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
                let loaded = loader.nucleon.clone(recursive: true)

                loaded.scale = .init(repeating: 0.45)

                content.add(loaded)
                nucleon = loaded

                // A cena vem com wrappers "Root" aninhados; ancorar no `gluon_conexoes`
                // (nome único) e usar seus irmãos evita pegar os quarks aninhados dentro
                // do QuarkDownToUp por engano.
                gluons = loaded.findEntity(named: "gluon_conexoes")
                let container = gluons?.parent ?? loaded
                let quarkNames: Set<String> = ["QuarkDown", "QuarkUp", "QuarkDownToUp"]
                quarkEntities = container.children.filter { quarkNames.contains($0.name) }
                downToUp = container.children.first { $0.name == "QuarkDownToUp" }
                wBoson = downToUp?.findEntity(named: "BosonW")

                // O bóson W e o quark up (aninhados no QuarkDownToUp) só aparecem na
                // transformação — desativa no idle para não renderizar os halos
                // transparentes do W (overdraw que trava o simulador).
                transformOnlyEntities = [wBoson, downToUp?.findEntity(named: "QuarkUp")].compactMap { $0 }
                for entity in transformOnlyEntities { entity.isEnabled = false }

                // Idle: Jitter em loop em todos os quarks/bóson. A timeline ToUp
                // (transformação) NÃO roda no idle — é disparada em triggerTransformation.
                playJitterLoops(from: loaded)

                vm.syncInteractionState(from: experienceState)
                applyInteractionState()
            }
            .gesture(spatialTapGesture)
            .simultaneousGesture(dragGesture)
            #if !os(visionOS)
            .ignoresSafeArea()
            .background(AppColors.iceWhite)
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

            // Ao chegar no núcleo, espera um instante e dispara o quarksScript.
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                vm.quarksIntroDialogue()
            }
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
        // Durante um diálogo, nenhuma interação com partícula é permitida.
        guard !dialogueManager.isShowingDialogue else { return }

        let tappedEntity = value.entity

        // O bóson W é descendente do QuarkDownToUp (um quark), então precisa ser
        // testado antes dos quarks. Cada ramo é fechado pelo estado de interação.
        if vm.interactionState.canInteractWithWBoson,
           let wBoson, tappedEntity.isDescendant(of: wBoson) {
            vm.interactionText = nil
            vm.startwBosonScriptDialogue()
            return
        }

        if vm.interactionState.canInteractWithQuarks,
           quarkEntities.contains(where: { tappedEntity.isDescendant(of: $0) }) {
            if experienceState == .insideProton {
                vm.interactionText = nil
                vm.onExperienceStateChange?(.quarks)
                vm.startQuarksDialogue()
            }
            return
        }

        if vm.interactionState.canInteractWithGluons,
           let gluons, tappedEntity.isDescendant(of: gluons) {
            vm.interactionText = nil
            vm.startGluonsDialogue()
            return
        }
    }

    func rotate(translation: CGSize) {
        guard let nucleon else { return }
        let dx = Float(translation.width) * 0.0005
        let dy = Float(translation.height) * 0.0005
        let qx = simd_quatf(angle: dy, axis: [1,0,0])
        let qy = simd_quatf(angle: dx, axis: [0,1,0])
        nucleon.transform.rotation = qy * qx * nucleon.transform.rotation
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
                try? await Task.sleep(for: .seconds(6.0))
                vm.startProtonQuarkTransformedDialogue()
            }

        case .leavingNucleus:
            zoomOutNucleon()

        default:
            break
        }
    }

    /// Afasta o núcleo (zoom out da cena do núcleo) e, ao terminar, entrega para o
    /// átomo continuar o zoom out (troca para `.zoomingOutFromNucleus`).
    func zoomOutNucleon() {
        guard let nucleon else {
            vm.onExperienceStateChange?(.zoomingOutFromNucleus)
            return
        }

        let duration: TimeInterval = 1.1
        var target = nucleon.transform
        target.scale = .one * 0.12  // recua o núcleo para longe antes da troca de cena
        nucleon.move(to: target, relativeTo: nucleon.parent, duration: duration, timingFunction: .easeIn)

        Task {
            try? await Task.sleep(for: .seconds(duration))
            vm.onExperienceStateChange?(.zoomingOutFromNucleus)
        }
    }

    func applyInteractionState() {
        // Ordem importa: quarks primeiro, wBoson por último. Como o wBoson é
        // descendente do QuarkDownToUp, ativá-lo por último garante que o alvo de
        // input dele não seja removido ao desativar os quarks.
        for quark in quarkEntities {
            quark.setInteractivity(enabled: vm.interactionState.canInteractWithQuarks)
        }
        if let gluons { gluons.setInteractivity(enabled: vm.interactionState.canInteractWithGluons) }
        if let wBoson { wBoson.setInteractivity(enabled: vm.interactionState.canInteractWithWBoson) }
    }
}

// MARK: - Entity Triggers
private extension NucleusView {

    func triggerTransformation() {
        guard !vm.animationPlayed else { return }
        vm.animationPlayed = true

        // Reativa o bóson W e o quark up — a partir daqui a timeline ToUp os revela.
        // Rejoga o Jitter deles em loop (o loop era feito pela notificação loopJitter
        // da cena, removida por causar cascata de playbacks — agora é só via código).
        for entity in transformOnlyEntities {
            entity.isEnabled = true
            playJitterLoops(from: entity)
        }

        // A transformação down→up (com o bóson W) é a timeline "ToUp" montada no RCP,
        // one-shot (sem loop). O Jitter idle segue rodando por baixo.
        playOneShot(keySuffix: "ToUp", on: downToUp)
    }
}

// MARK: - RCP Timelines
private extension NucleusView {

    /// Toca em loop as timelines "Jitter" (idle) de toda a hierarquia, ignorando a
    /// timeline "ToUp" (transformação), que é disparada só quando o quark decai.
    func playJitterLoops(from entity: Entity) {
        if let library = entity.components[AnimationLibraryComponent.self] {
            for (key, resource) in library.animations
            where key.hasSuffix("Jitter__auto_generated_looping") {
                entity.playAnimation(resource.repeat())
            }
        }
        for child in entity.children {
            playJitterLoops(from: child)
        }
    }

    /// Toca uma vez (sem loop) a timeline cujo nome termina em `keySuffix`.
    func playOneShot(keySuffix: String, on entity: Entity?) {
        guard let entity,
              let library = entity.components[AnimationLibraryComponent.self] else { return }
        for (key, resource) in library.animations where key.hasSuffix(keySuffix) {
            entity.playAnimation(resource)
        }
    }
}
