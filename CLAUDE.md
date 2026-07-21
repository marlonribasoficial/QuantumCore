# QuantumCore — CLAUDE.md

## O que o app faz

QuantumCore é uma experiência educativa interativa para iOS, iPadOS e visionOS sobre física de partículas subatômicas. O usuário explora um átomo em 3D, interagindo com seus componentes (elétron, fóton, núcleo, quarks, glúons, bóson Z, bóson W) em sequência guiada por um robô narrador. Cada interação desbloqueia um diálogo explicativo e credita energia ao núcleo. A experiência tem um fluxo linear: introdução → exploração do átomo → exploração do núcleo → encerramento.

Desenvolvido para o Swift Student Challenge 2025.

---

## Estrutura de pastas atual

```
QuantumCore/
│
├── Core/                              ← Swift Package local (sem SwiftUI/RealityKit)
│   └── Sources/Core/
│       ├── Core.swift                 # Namespace público
│       ├── ExperienceState.swift      # Enum com 34 cases + interactionConfiguration()
│       ├── InteractionState.swift     # Struct de flags de interação
│       ├── OverlayType.swift          # Enum de partículas + InteractionText
│       ├── Scripts.swift              # Todos os textos de diálogo (strings estáticas)
│       ├── DialogueEngine.swift       # Máquina de estado do diálogo (struct puro) + DialogueSequence
│       └── DeviceTypes.swift          # DeviceTab, IntroPhase, DeviceMode, HomeOverlay
│
└── QuantumCore/                       ← App target (SwiftUI + RealityKit)
    ├── QuantumCoreApp.swift            # Entry point
    ├── HomeView.swift                  # Tela inicial / menu
    ├── LoadingView.swift               # Tela de carregamento
    │
    ├── RealityKitViews/
    │   ├── AtomView.swift              # Cena 3D do átomo — apenas render + gestos
    │   ├── AtomViewModel.swift         # Lógica de estado e diálogos do átomo
    │   ├── NucleusView.swift           # Cena 3D do núcleo — apenas render + gestos
    │   ├── NucleusViewModel.swift      # Lógica de estado e diálogos do núcleo
    │   └── ParticlePanel.swift         # Painel de informações da partícula
    │
    ├── Panel/
    │   ├── ExperienceRoot.swift        # Coordenador raiz da experiência
    │   ├── DeviceScreen.swift          # Tela do dispositivo/robô — apenas render
    │   ├── DeviceScreenViewModel.swift # Lógica de fluxo intro/ending
    │   ├── HomePanel.swift             # Container do painel Home
    │   ├── SystemPanel.swift           # Container do painel System
    │   ├── RobotView.swift             # Visual do robô narrador
    │   ├── SystemOfflineView.swift     # Tela de sistema offline
    │   └── RoundedCorner.swift         # Helper de shape
    │
    ├── States/
    │   └── OverlayType+Color.swift     # Extensão de cor (SwiftUI) para OverlayType do Core
    │
    ├── Dialogue/
    │   ├── DialogueManager.swift       # Wrapper @Published sobre DialogueEngine do Core
    │   ├── DialogueBubbleView.swift    # Bolha de diálogo
    │   └── DialogueBox.swift           # Container do diálogo
    │
    ├── Systems/
    │   ├── SystemView.swift            # View do painel de sistemas
    │   ├── SystemFeedback.swift        # Feedback visual pós-interação
    │   ├── SystemLabel.swift           # Label de sistema
    │   └── ModalContainer.swift        # Container modal
    │
    ├── TopBar/
    │   ├── TopBar.swift                # Barra superior
    │   ├── TabButton.swift             # Botão de aba
    │   └── BatteryView.swift           # Indicador de energia
    │
    ├── Entity/
    │   ├── EntityTransform.swift       # Extensão de transformação de entidade
    │   ├── EntityDescendant.swift      # Extensão de hierarquia de entidade
    │   └── EntityInteractivity.swift   # Extensão de interatividade de entidade
    │
    └── Helpers/
        ├── AssetLoader.swift           # Carrega modelos RealityKit (@EnvironmentObject)
        ├── AppColors.swift             # Constantes de cor (SwiftUI Color)
        └── FontInitializer.swift       # Inicialização de fontes customizadas
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
│  @MainActor ObservableObject                │
│  AtomViewModel, NucleusViewModel,           │
│  DeviceScreenViewModel                      │
│  → Detém lógica de negócio, diálogos,       │
│    transições de estado, callbacks          │
└────────────────────┬────────────────────────┘
                     │ @StateObject / @ObservedObject
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
- **Estado** → ViewModel muta → View observa via `@Published`
- **Energia** → ViewModel dispara callback `onEnergyGained` → View incrementa `@Binding`
- **Diálogo** → ViewModel cria `DialogueSequence` (Core) → `DialogueManager` executa → View observa `isShowingDialogue`
- **Entidades RealityKit** → sempre `@State` na View; ViewModel nunca toca em `Entity`

---

## Regras

1. **Nenhuma lógica de negócio em Views.** Views só renderizam e repassam eventos.
2. **Core não importa SwiftUI nem RealityKit.** Se precisar de `Color`, crie uma extensão no app target.
3. **Entidades RealityKit ficam na View** como `@State`. ViewModels nunca referenciam `Entity`.
4. **`DialogueSequence` e `DialogueEngine` são do Core.** `DialogueManager` é só o wrapper `@Published`.
5. **Transições de `ExperienceState` passam pelo ViewModel** via `setExperienceState(_:)` — nunca mutadas diretamente na View.
6. **Energia (`coreEnergy`) é um `@Binding` do pai.** ViewModels disparam `onEnergyGained?()` e nunca tocam no binding diretamente.
7. **Um passo de cada vez.** Cada mudança deve deixar o projeto compilando antes de avançar.
8. **Plataformas suportadas:** iOS 18+, iPadOS 18+, visionOS 1+. Não usar APIs exclusivas de uma plataforma sem `#if os(...)`.
