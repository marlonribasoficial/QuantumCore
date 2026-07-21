# QuantumCore — CLAUDE.md

## O que o app faz

QuantumCore é uma experiência educativa interativa para iOS, iPadOS e visionOS sobre física de partículas subatômicas. O usuário explora um átomo em 3D, interagindo com seus componentes (elétron, fóton, núcleo, quarks, glúons, bóson Z, bóson W) em sequência guiada por um robô narrador. Cada interação desbloqueia um diálogo explicativo e credita energia ao núcleo. A experiência tem um fluxo linear: introdução → exploração do átomo → exploração do núcleo → encerramento.

Desenvolvido para o Swift Student Challenge 2025.

**Design:** `DESIGN.md` na raiz do repo é a fonte única de verdade das decisões de design, modelos 3D e animações. Consultar antes de qualquer trabalho visual.

---

## Estrutura de pastas atual

```
QuantumCore/
│
├── CLAUDE.md
├── DESIGN.md                          ← Fonte única de verdade de design/3D/animações
│
├── Core/                              ← Swift Package local (sem SwiftUI/RealityKit)
│   └── Sources/Core/
│       ├── ExperienceState.swift      # Enum de estados da experiência + interactionConfiguration()
│       ├── InteractionState.swift     # Struct de flags de interação
│       ├── OverlayType.swift          # Enum de partículas + InteractionText
│       ├── Scripts.swift              # Todos os textos de diálogo (strings estáticas)
│       ├── DialogueEngine.swift       # Máquina de estado do diálogo (struct puro) + DialogueSequence
│       ├── EnergyReward.swift         # Valores de energia creditados por interação
│       └── DeviceTypes.swift          # DeviceTab, IntroPhase, DeviceMode, HomeOverlay
│
└── QuantumCore/                       ← App target (SwiftUI + RealityKit)
    ├── App/
    │   ├── QuantumCoreApp.swift        # Entry point: LoadingView → StartView; visionOS: ImmersiveSpace "AtomSpace"
    │   ├── LoadingView.swift           # Tela de carregamento (enquanto AssetLoader carrega)
    │   ├── StartView.swift             # Tela inicial — dá lugar à ExperienceRoot
    │   ├── AtomImmersiveView.swift     # visionOS: AtomView dentro do ImmersiveSpace
    │   └── HomeView.swift              # LEGADO — não referenciado em lugar nenhum
    │
    ├── Experience/
    │   ├── ExperienceRoot.swift        # Coordenador raiz da experiência
    │   ├── SystemFeedbackPresenting.swift  # Protocolo: feedback compartilhado (energia → modal → esconder)
    │   ├── Atom/
    │   │   ├── AtomView.swift          # Cena 3D do átomo — apenas render + gestos
    │   │   └── AtomViewModel.swift     # Lógica de estado e diálogos do átomo
    │   └── Nucleus/
    │       ├── NucleusView.swift       # Cena 3D do núcleo — apenas render + gestos
    │       └── NucleusViewModel.swift  # Lógica de estado e diálogos do núcleo
    │
    ├── Device/                         ← Tela do dispositivo/robô (Max)
    │   ├── DeviceScreen.swift          # Render da tela do dispositivo
    │   ├── DeviceScreenViewModel.swift # Lógica de fluxo intro/ending
    │   ├── HomePanel.swift             # Painel Home (usa CoreTransformationView / SystemOnlineView)
    │   ├── SystemPanel.swift           # Painel System (usa CoreChamberView)
    │   ├── CoreChamberView.swift       # Câmara do core (online/offline)
    │   ├── CoreTransformationView.swift # Animação de transformação do core
    │   ├── SystemOnlineView.swift      # Tela de sistema online
    │   ├── SystemOfflineView.swift     # Tela de sistema offline
    │   ├── RobotView.swift             # Visual do robô narrador
    │   └── MaxFaceView.swift           # Rosto do robô Max
    │
    ├── Dialogue/
    │   ├── DialogueManager.swift       # Wrapper @Observable sobre DialogueEngine do Core
    │   ├── DialogueBubbleView.swift    # Bolha de diálogo
    │   └── DialogueBox.swift           # Container do diálogo
    │
    ├── Components/                     ← Componentes SwiftUI reutilizáveis
    │   ├── QuantumCoreView.swift       # Gráfico do Quantum Core (anéis de sistemas + varredura)
    │   ├── ConcentricCore.swift        # Anéis concêntricos animáveis
    │   ├── InteractionOverlay.swift    # Dica de gesto na base da cena
    │   ├── ParticlePanel.swift         # Painel de informações da partícula
    │   ├── SystemFeedback.swift        # Feedback visual pós-interação
    │   ├── ModalContainer.swift        # Container modal
    │   ├── TopBar.swift                # Barra superior
    │   ├── TabButton.swift             # Botão de aba
    │   ├── ScanlineOverlay.swift       # Overlay de scanlines (estética CRT)
    │   ├── StartBackground.swift       # Fundo da tela inicial
    │   ├── LookInsideButton.swift      # Botão "Look inside" da StartView
    │   └── AboutYouSheet.swift         # Sheet "About you" da StartView
    │
    ├── RealityKit/                     ← Extensões de Entity
    │   ├── EntityTransform.swift       # Transformação de entidade
    │   ├── EntityDescendant.swift      # Hierarquia de entidade
    │   └── EntityInteractivity.swift   # Interatividade de entidade
    │
    ├── Helpers/
    │   ├── AssetLoader.swift           # Carrega modelos RealityKit (@Observable, injetado via .environment)
    │   ├── ExperienceModel.swift       # visionOS: estado compartilhado da experiência (@Observable)
    │   ├── AppColors.swift             # Constantes de cor (SwiftUI Color)
    │   ├── StartTheme.swift            # StartPalette, AppLayout, AppFonts
    │   ├── FontInitializer.swift       # Registro de fontes customizadas
    │   └── OverlayType+Color.swift     # Extensão de cor (SwiftUI) para OverlayType do Core
    │
    └── Resources/                      ← Modelos .usdz (partículas + variantes "Pulsing") e fontes .ttf
```

---

## Arquitetura alvo

### Camadas

```
┌─────────────────────────────────────────────┐
│  Core (Swift Package)                       │
│  Sem SwiftUI. Sem RealityKit. Só Foundation │
│  ExperienceState, InteractionState,         │
│  OverlayType, Scripts, DialogueEngine,      │
│  DeviceTypes                                │
└────────────────────┬────────────────────────┘
                     │ import Core
┌────────────────────▼────────────────────────┐
│  ViewModels (app target)                    │
│  @MainActor @Observable                     │
│  AtomViewModel, NucleusViewModel,           │
│  DeviceScreenViewModel                      │
│  → Detém lógica de negócio, diálogos,       │
│    transições de estado, callbacks          │
└────────────────────┬────────────────────────┘
                     │ @State / .environment
┌────────────────────▼────────────────────────┐
│  Views (app target)                         │
│  SwiftUI + RealityKit                       │
│  Apenas: renderizar, observar VM,           │
│  repassar gestos e bindings                 │
│  Entidades RealityKit ficam aqui (@State)   │
└─────────────────────────────────────────────┘
```

### Fluxo de dados

- **Gestos** → View detecta → chama método no ViewModel
- **Estado** → ViewModel muta → View observa via `@Observable` (Observation)
- **Energia** → ViewModel dispara callback `onEnergyGained` → View incrementa `@Binding`
- **Diálogo** → ViewModel cria `DialogueSequence` (Core) → `DialogueManager` executa → View observa `isShowingDialogue`
- **Entidades RealityKit** → sempre `@State` na View; ViewModel nunca toca em `Entity`

---

## Regras

1. **Nenhuma lógica de negócio em Views.** Views só renderizam e repassam eventos.
2. **Core não importa SwiftUI nem RealityKit.** Se precisar de `Color`, crie uma extensão no app target.
3. **Entidades RealityKit ficam na View** como `@State`. ViewModels nunca referenciam `Entity`.
4. **`DialogueSequence` e `DialogueEngine` são do Core.** `DialogueManager` é só o wrapper `@Observable`.
5. **Transições de `ExperienceState` passam pelo ViewModel** via `setExperienceState(_:)` — nunca mutadas diretamente na View.
6. **Energia (`coreEnergy`) é um `@Binding` do pai.** ViewModels disparam `onEnergyGained?()` e nunca tocam no binding diretamente.
7. **Um passo de cada vez.** Cada mudança deve deixar o projeto compilando antes de avançar.
8. **Plataformas suportadas:** iOS 18+, iPadOS 18+, visionOS 1+. Não usar APIs exclusivas de uma plataforma sem `#if os(...)`.
