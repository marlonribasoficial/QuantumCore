public enum ExperienceState: Sendable {
    case intro
    case lookingToAtom
    case exploring
    case shellIntro
    case shellDiscovered
    case electronSpawned
    case electronInteracted
    case photonSpawned
    case photonInteracted
    case nucleus
    case closeToNucleus
    case zoomingIntoNucleus
    case insideProton
    case quarks
    case quarksInteracted
    case gluons
    case gluonsInteracted
    case quarkTransforming
    case wBosonSpawned
    case wBosonInteracted
    case leavingNucleus
    case zoomingOutFromNucleus
    case backToShell
    case zBosonSpawned
    case zBosonInteracted

    public var isInsideNucleus: Bool {
        switch self {
        case .insideProton,
             .quarks,
             .quarksInteracted,
             .gluons,
             .gluonsInteracted,
             .quarkTransforming,
             .wBosonSpawned,
             .wBosonInteracted:
            return true
        default:
            return false
        }
    }

    public var canShowButton: Bool {
        switch self {
        case .lookingToAtom,
             .exploring,
             .nucleus:
            return true
        default:
            return false
        }
    }

    public var interactionConfiguration: InteractionState {
        switch self {

        case .intro,
             .lookingToAtom:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithShell: false,
                canInteractWithNucleus: false,
                canInteractWithElectron: false,
                canInteractWithPhoton: false,
                canInteractWithZBoson: false
            )

        case .exploring:
            return InteractionState(
                canRotate: true,
                canZoom: true
            )

        case .shellIntro:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithShell: false
            )

        case .shellDiscovered:
            return InteractionState(
                canRotate: true,
                canZoom: false,
                canInteractWithShell: true,
                canInteractWithNucleus: false
            )

        case .electronSpawned:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithShell: false,
                canInteractWithElectron: true
            )

        case .electronInteracted:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithShell: false,
                canInteractWithElectron: false
            )

        case .photonSpawned:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithPhoton: true
            )

        case .photonInteracted:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithPhoton: false
            )

        case .nucleus:
            return InteractionState(
                canRotate: true,
                canZoom: true,
                canInteractWithNucleus: false
            )

        case .closeToNucleus,
             .zoomingIntoNucleus:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithNucleus: false
            )

        case .insideProton:
            return InteractionState(
                canRotate: true,
                canZoom: false,
                canInteractWithQuarks: true
            )

        case .quarks:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithQuarks: true
            )

        case .quarksInteracted:
            return InteractionState(
                canRotate: true,
                canZoom: true,
                canInteractWithQuarks: false
            )

        case .gluons:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithGluons: true
            )

        case .gluonsInteracted:
            return InteractionState(
                canRotate: true,
                canZoom: true,
                canInteractWithGluons: false
            )

        case .quarkTransforming:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithQuarks: false
            )

        case .wBosonSpawned:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithWBoson: true
            )

        case .wBosonInteracted:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithWBoson: false
            )

        case .leavingNucleus,
             .zoomingOutFromNucleus:
            return InteractionState(
                canRotate: false,
                canZoom: false
            )

        case .backToShell:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithShell: true
            )

        case .zBosonSpawned:
            return InteractionState(
                canRotate: false,
                canZoom: false,
                canInteractWithZBoson: true
            )

        case .zBosonInteracted:
            return InteractionState(
                canRotate: true,
                canZoom: true,
                canInteractWithZBoson: false
            )
        }
    }
}
