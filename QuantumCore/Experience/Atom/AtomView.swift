import SwiftUI
import RealityKit
import Core

@MainActor
struct AtomView: View {

    // MARK: - ViewModel
    @State private var vm = AtomViewModel()

    // MARK: - 3D Models Loader
    @Environment(AssetLoader.self) var loader

    // MARK: - Entities (ficam na View — objetos de referência do RealityKit)
    @State private var atom: Entity?
    @State private var nucleus: Entity?
    @State private var electronShell: Entity?
    @State private var electron: Entity?
    @State private var photon: Entity?
    @State private var particles: Entity?
    @State private var zBoson: Entity?

    // MARK: - Bindings do pai
    @Binding var coreEnergy: Int
    @Binding var canPlay: Bool
    var onZBosonFinished: (() -> Void)? = nil

    // MARK: - Constants
    private let electronShellInteractionScale: Float = 2.0
    private let nucleusInteractionScale: Float = 400.0

    // MARK: - Body
    var body: some View {
        #if os(visionOS)
        atomContent
        #else
        NavigationStack {
            atomContent
        }
        .navigationBarBackButtonHidden(true)

        if !vm.dialogueManager.isShowingDialogue, vm.experienceState.canShowButton {
            overlayButton
        }
        #endif
    }

    private var atomContent: some View {
        ZStack {
            if vm.experienceState.isInsideNucleus {
                NucleusView(
                    experienceState: Binding(
                        get: { vm.experienceState },
                        set: { vm.setExperienceState($0) }
                    ),
                    dialogueManager: vm.dialogueManager,
                    coreEnergy: $coreEnergy
                )
                .task { try? await Task.sleep(for: .seconds(1.0)) }
                .transition(.opacity)
            } else {
                atomRealityView
                    .transition(.opacity)
            }

            uiLayer
        }
        // Crossfade entre a cena do núcleo e a do átomo (encadeia os dois zoom outs).
        .animation(.easeInOut(duration: 0.6), value: vm.experienceState.isInsideNucleus)
        #if os(visionOS)
        .ornament(
            visibility: vm.dialogueManager.isShowingDialogue ? .visible : .hidden,
            attachmentAnchor: .scene(.bottom),
            contentAlignment: .top
        ) {
            DialogueBubbleView(manager: vm.dialogueManager, type: vm.selectedOverlay)
                .frame(width: 700)
                .padding(.bottom, 32)
        }
        #endif
        .onAppear {
            vm.onEnergyGained = { coreEnergy += EnergyReward.particleInteraction }
            vm.onZBosonFinished = onZBosonFinished
        }
        .onChange(of: vm.experienceState) { _, newState in
            applyInteractionState()
            handleStateChange(newState)
        }
        .onChange(of: canPlay) { _, newValue in
            if newValue {
                Task {
                    try? await Task.sleep(for: .seconds(1.0))
                    vm.setExperienceState(.lookingToAtom)
                }
            }
        }
    }
}

// MARK: - RealityView Components
private extension AtomView {

    var atomRealityView: some View {
        RealityView { content in
            let atomScene = loader.atom.clone(recursive: true)

            // A cena Atomo do RCP tem ~1,21m de diâmetro; o Atom.usdz antigo tinha 2,0m.
            // O container compensa a diferença para preservar os thresholds de escala do
            // ViewModel (3, 500, 1500…) e o tamanho relativo das partículas spawnadas.
            atomScene.scale = .one * 1.65
            let loadedAtom = Entity()
            loadedAtom.addChild(atomScene)

            loadedAtom.enableCollision()
            content.add(loadedAtom)

            atom = loadedAtom
            nucleus = loadedAtom.findEntity(named: "Nucleo")
            electronShell = loadedAtom.findEntity(named: "Eletrosfera")

            #if os(visionOS)
            // Posiciona o átomo 1.5m à frente e na altura dos olhos do usuário
            loadedAtom.position = [0, 1.5, -1.5]
            #endif

            // Timelines do RCP (respiração da eletrosfera + spin do núcleo).
            // O RCP não tem toggle de loop — o loop é sempre feito por código.
            playAllTimelines(from: atomScene)

            if vm.experienceState == .zoomingOutFromNucleus {
                loadedAtom.scale = .one * 900
                vm.currentScale = 900
            } else {
                loadedAtom.scale = .one * vm.currentScale
            }

            vm.checkScaleThresholds()
            applyInteractionState()
        }
        .gesture(spatialTapGesture)
        .simultaneousGesture(magnificationGesture)
        .simultaneousGesture(dragGesture)
        #if !os(visionOS)
        .background(.black)
        .ignoresSafeArea()
        #endif
    }

    var uiLayer: some View {
        ZStack {
            #if !os(visionOS)
            if vm.dialogueManager.isShowingDialogue {
                DialogueBubbleView(manager: vm.dialogueManager, type: vm.selectedOverlay)
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

            if let text = vm.interactionText {
                InteractionOverlay(text: text)
            }
        }
    }

    var overlayButton: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    withAnimation {
                        handleMagnification(value: 10.0)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(StartPalette.screenBase.opacity(0.85))

                        Circle()
                            .stroke(StartPalette.accent.opacity(0.55), lineWidth: 1.5)

                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(StartPalette.cream)
                            .accessibilityHidden(true)
                    }
                    .frame(width: 50, height: 50)
                    .shadow(color: StartPalette.accent.opacity(0.35), radius: 12)
                }
                .accessibilityLabel("Zoom in")
                .accessibilityHint("Double tap to zoom into the atom")
                .hoverEffect()
                .padding()
            }

            Spacer()
        }
    }
}

// MARK: - Gestures
private extension AtomView {

    var spatialTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                handleTapInteraction(at: value)
            }
    }

    var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                handleMagnification(value: value.magnification)
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                rotateAtom(translation: value.translation)
            }
    }

    func handleTapInteraction(at value: EntityTargetValue<SpatialTapGesture.Value>) {
        // Durante um diálogo, nenhuma interação com partícula é permitida
        // (abrir card, coletar, spawnar) — só depois que a fala termina.
        guard !vm.dialogueManager.isShowingDialogue else { return }

        let tappedEntity = value.entity

        if let zBoson, tappedEntity == zBoson || tappedEntity.isDescendant(of: zBoson) {
            vm.interactionText = nil
            vm.startZBosonDialogue()
            return
        }

        if let nucleus, vm.interactionState.canInteractWithNucleus, tappedEntity.isDescendant(of: nucleus) {
            return
        }

        if let electronShell, vm.interactionState.canInteractWithShell, tappedEntity.isDescendant(of: electronShell) {
            if vm.experienceState == .backToShell {
                if vm.wasParticlesInteracted { return }
                // O BosonZ já vem dentro da cena ParticlesBosonZ (revelado pela
                // coreografia ~3,1s). Não há spawn separado — só ativamos a
                // interação com ele depois que a coreografia o revela.
                #if os(visionOS)
                let spawnPosition = tappedEntity.position(relativeTo: nil)
                vm.wasParticlesInteracted = true
                Task {
                    await spawnParticles(at: spawnPosition)
                    vm.interactionText = nil
                    try? await Task.sleep(for: .seconds(3.3))
                    vm.setExperienceState(.zBosonSpawned)
                    try? await Task.sleep(for: .seconds(0.5))
                    vm.interactionText = .clickParticle
                }
                #else
                if let hit = value.hitTest(point: value.location, in: .local).first {
                    vm.wasParticlesInteracted = true
                    Task {
                        await spawnParticles(at: hit.position)
                        vm.interactionText = nil
                        try? await Task.sleep(for: .seconds(3.3))
                        vm.setExperienceState(.zBosonSpawned)
                        try? await Task.sleep(for: .seconds(0.5))
                        vm.interactionText = .clickParticle
                    }
                }
                #endif
            } else {
                if vm.wasElectronSpawned { return }
                // Limpa a dica "tap the electron shell" ao tocar no shell; a de
                // coletar o elétron só aparece quando o electronScript termina
                // (ver electronSpawnedDialogue).
                vm.interactionText = nil
                #if os(visionOS)
                let spawnPosition = tappedEntity.position(relativeTo: nil)
                vm.wasElectronSpawned = true
                Task { await spawnElectronEntity(at: spawnPosition) }
                #else
                if let hit = value.hitTest(point: value.location, in: .local).first {
                    vm.wasElectronSpawned = true
                    Task { await spawnElectronEntity(at: hit.position) }
                }
                #endif
            }
            return
        }

        if let electron, vm.interactionState.canInteractWithElectron, tappedEntity.isDescendant(of: electron) {
            vm.interactionText = nil
            vm.startElectronDialogue()
            return
        }

        if let photon, vm.interactionState.canInteractWithPhoton, tappedEntity.isDescendant(of: photon) {
            vm.interactionText = nil
            vm.startPhotonDialogue()
            return
        }
    }

    func handleMagnification(value: CGFloat) {
        guard vm.interactionState.canZoom, let atom else { return }

        let damping: Float = 0.1
        let delta = 1 + (Float(value) - 1) * damping
        let newScale = vm.currentScale * delta

        guard newScale >= vm.minScale, newScale <= vm.maxScale else { return }

        vm.currentScale = newScale
        atom.scale = .one * newScale

        vm.checkScaleThresholds()
        applyInteractionState()
    }

    func rotateAtom(translation: CGSize) {
        guard vm.interactionState.canRotate, let atom else { return }
        let dx = Float(translation.width) * 0.0005
        let dy = Float(translation.height) * 0.0005
        let qx = simd_quatf(angle: dy, axis: [1,0,0])
        let qy = simd_quatf(angle: dx, axis: [0,1,0])
        atom.transform.rotation = qy * qx * atom.transform.rotation
    }

    func animateZoom(to scale: Float, duration: TimeInterval) async {
        guard let atom else { return }

        vm.currentScale = scale

        atom.move(
            to: Transform(scale: .one * scale),
            relativeTo: atom.parent,
            duration: duration,
            timingFunction: .easeInOut
        )

        try? await Task.sleep(for: .seconds(duration))
    }
}

// MARK: - Experience State Handler
private extension AtomView {

    func handleStateChange(_ newState: ExperienceState) {
        switch newState {

        case .lookingToAtom:
            vm.lookingToAtomScriptDialogue()

        case .electronSpawned:
            vm.electronSpawnedDialogue()

        case .electronInteracted:
            // Animação de saída do elétron (placeholder — a definitiva virá do RCP).
            if let electron { electron.slideOut(deltaX: 100, deltaY: 10, deltaZ: 3) }

            Task {
                // Ao mesmo tempo que o elétron sai: spawna o fóton com a FotonSpawn
                // (toca uma vez). Espera a FotonSpawn (~3s) antes do diálogo.
                await spawnPhotonEntity(at: vm.electronPos)
                try? await Task.sleep(for: .seconds(3.0))
                vm.photonFound()
            }

        case .photonInteracted:
            if let photon { photon.slideOut(deltaX: -500, deltaY: -4, deltaZ: 5) }
            Task {
                try? await Task.sleep(for: .seconds(1.0))
                vm.goingToNucleusDialogue()
            }
            vm.maxScale = 700

        case .zoomingIntoNucleus:
            vm.scaleBeforeNucleus = vm.currentScale

            Task {
                await animateZoom(to: 1270.0, duration: 3.0)
                await MainActor.run {
                    vm.setExperienceState(.insideProton)
                }
            }

        case .zoomingOutFromNucleus:
            Task {
                try? await Task.sleep(for: .milliseconds(50))
                await animateZoom(to: 20.0, duration: 3.0)
                vm.backToShellDialogue()
            }

        default:
            break
        }
    }
}

// MARK: - Interaction State
private extension AtomView {

    func applyInteractionState() {
        if let nucleus { nucleus.setInteractivity(enabled: vm.interactionState.canInteractWithNucleus) }
        if let electronShell { electronShell.setInteractivity(enabled: vm.interactionState.canInteractWithShell) }
        if let electron { electron.setInteractivity(enabled: vm.interactionState.canInteractWithElectron) }
        if let photon { photon.setInteractivity(enabled: vm.interactionState.canInteractWithPhoton) }
        if let zBoson { zBoson.setInteractivity(enabled: vm.interactionState.canInteractWithZBoson) }
    }
}

// MARK: - RCP Timelines
private extension AtomView {

    /// Toca em loop todas as timelines da cena, onde quer que estejam na hierarquia
    /// (cenas do RCP podem expor animações no root ou em sub-entidades referenciadas).
    ///
    /// Cada timeline do RCP entra na AnimationLibrary duas vezes: a versão normal e uma
    /// variante "__auto_generated_looping". Toca só a variante de loop — tocar as duas na
    /// mesma entidade faz a segunda cancelar a primeira.
    func playAllTimelines(from entity: Entity) {
        if let library = entity.components[AnimationLibraryComponent.self] {
            let all = Array(library.animations)
            let looping = all.filter { $0.key.hasSuffix("__auto_generated_looping") }
            let loops = (looping.isEmpty ? all : looping).map { $0.value }
            // Se a mesma entidade tem várias timelines (ex.: Eletron = Jitter +
            // Opacidade), agrupa — senão o segundo playAnimation substituiria o
            // primeiro e só uma tocaria.
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
}

// MARK: - Entity Spawning
private extension AtomView {

    func spawnElectronEntity(at worldPosition: SIMD3<Float>) async {
        guard let atom else { return }
        let loaded = loader.electron.clone(recursive: true)

        // Cena Eletron do RCP tem ~0,55m (Electron.usdz antigo: 2,0m) → 0,0005 × 3,65
        loaded.scale = .one * 0.0018

        let localPos = atom.convert(position: worldPosition, from: nil)
        let direction = normalize(localPos)
        let adjustedPos = localPos + (direction * -0.007)

        loaded.position = adjustedPos
        vm.electronPos = adjustedPos

        atom.addChild(loaded)

        electron = loaded
        vm.setExperienceState(.electronSpawned)

        playAllTimelines(from: loaded)
    }

    func spawnPhotonEntity(at worldPosition: SIMD3<Float>) async {
        guard let atom else { return }
        let loaded = loader.photon.clone(recursive: true)

        // Cena Foton do RCP tem 0,22m (Photon.usdz antigo: 2,0m) → 0,00017 × 9,1
        loaded.scale = .one * 0.0015
        loaded.position = worldPosition

        atom.addChild(loaded)

        photon = loaded

        playPhotonScene(from: loaded)
    }

    /// Toca a cena do Foton no spawn: a timeline "FotonSpawn" uma vez (aparição) e,
    /// só **depois que ela termina**, o Spin/Jitter entram em loop.
    func playPhotonScene(from entity: Entity) {
        if let library = entity.components[AnimationLibraryComponent.self] {
            let all = Array(library.animations)

            // Idle (todas menos a FotonSpawn) — vão em loop no fim da aparição.
            let idleLoops = all
                .filter { $0.key.hasSuffix("__auto_generated_looping") && !$0.key.contains("FotonSpawn") }
                .map { $0.value }

            if let spawn = all.first(where: { $0.key.hasSuffix("/FotonSpawn") })?.value {
                entity.playAnimation(spawn)
                let duration = spawn.definition.duration
                Task {
                    try? await Task.sleep(for: .seconds(duration))
                    playIdleLoops(idleLoops, on: entity)
                }
            } else {
                playIdleLoops(idleLoops, on: entity)
            }
        }
        for child in entity.children {
            playPhotonScene(from: child)
        }
    }

    /// Toca as timelines idle em loop, agrupadas quando são várias na mesma
    /// entidade (senão o último playAnimation substituiria os anteriores).
    func playIdleLoops(_ loops: [AnimationResource], on entity: Entity) {
        guard !loops.isEmpty else { return }
        if loops.count == 1 {
            entity.playAnimation(loops[0].repeat())
        } else if let group = try? AnimationResource.group(with: loops.map { $0.repeat() }) {
            entity.playAnimation(group)
        } else {
            loops.forEach { entity.playAnimation($0.repeat()) }
        }
    }

    func spawnParticles(at worldPosition: SIMD3<Float>) async {
        guard let atom else { return }
        let loaded = loader.particles.clone(recursive: true)

        // ▼▼▼ ESCALA DA CENA ParticlesBosonZ — ajuste aqui pra testar ▼▼▼
        loaded.scale = .one * 0.0012

        let localPos = atom.convert(position: worldPosition, from: nil)
        let direction = normalize(localPos)
        let adjustedPos = localPos + (direction * -0.007)

        loaded.position = adjustedPos

        atom.addChild(loaded)

        particles = loaded

        // O BosonZ tocável é o que está dentro da própria cena (revelado pela
        // coreografia) — não há mais spawn separado.
        zBoson = loaded.findEntity(named: "BosonZ")

        // A cena tem a coreografia "Particles" (one-shot) e loops aninhados
        // (Jitter/Opacidade dos electrons + Jitter do BosonZ). Percorre toda a
        // hierarquia (a cena vem com wrappers "Root" aninhados).
        playParticlesScene(from: loaded)
    }

    /// Toca a cena ParticlesBosonZ: a timeline principal "Particles" uma vez
    /// (coreografia dos electrons + reveal do BosonZ) e as timelines aninhadas
    /// (Jitter/Opacidade) em loop.
    func playParticlesScene(from entity: Entity) {
        if let library = entity.components[AnimationLibraryComponent.self] {
            let all = Array(library.animations)

            // Loops aninhados (Jitter/Opacidade), agrupados por entidade.
            let loops = all
                .filter { $0.key.hasSuffix("__auto_generated_looping") && !$0.key.contains("/Particles") }
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

            // Animação principal "Particles" — one-shot.
            if let main = all.first(where: { $0.key.hasSuffix("/Particles") })?.value {
                entity.playAnimation(main)
            }
        }
        for child in entity.children {
            playParticlesScene(from: child)
        }
    }
}
