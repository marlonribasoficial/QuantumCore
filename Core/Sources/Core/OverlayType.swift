import CoreGraphics

/// Dicas de gesto exibidas sobre a cena. Os textos dos beats com gesto do
/// roteiro são reproduzidos literalmente; `zoomIn` é a única dica extra
/// (necessária para o gesto de pinça que o protótipo não tinha).
public enum InteractionText: String, Sendable {
    case zoomIn = "Zoom in"
    case tapShell = "Tap the electron shell."
    case collectElectron = "Collect the electron."
    case collectPhoton = "Collect the photon."
    case closerToCenter = "Let's get closer to the center."
    case collectQuarks = "Collect the quarks."
    case clickGluon = "Click on what's between the quarks."
    case clickParticle = "Click on this particle."

    /// Tipo de gesto que a dica pede (dirige o ícone nativo da overlay).
    public var gesture: GestureKind {
        switch self {
        case .zoomIn, .closerToCenter: return .zoom
        case .clickParticle:           return .point
        default:                       return .tap
        }
    }
}

/// Gestos possíveis pedidos por uma dica de interação.
public enum GestureKind: Sendable {
    case tap
    case point
    case zoom
}

public enum OverlayType: Sendable {
    case electron
    case photon
    case quarks
    case gluons
    case wBoson
    case zBoson

    public var name: String {
        switch self {
        case .electron: return "Electron"
        case .photon:   return "Photon"
        case .quarks:   return "Quark"
        case .gluons:   return "Gluon"
        case .wBoson:   return "W Boson"
        case .zBoson:   return "Z Boson"
        }
    }

    public var charges: [String] {
        switch self {
        case .electron:
            return ["-1"]
        case .quarks:
            return ["Up: +2/3", "Down: -1/3"]
        case .wBoson:
            return ["+1", "-1"]
        default:
            return ["No charge"]
        }
    }

    public var system: String {
        switch self {
        case .electron: return "System Flow"
        case .photon:   return "Visual Systems"
        case .quarks:   return "Structural Core"
        case .gluons:   return "Core Stability"
        case .wBoson:   return "Transformation Systems"
        case .zBoson:   return "System Balance"
        }
    }

    public var modelName: String {
        switch self {
        case .electron: return "Electron"
        case .photon:   return "Photon"
        case .quarks:   return "Quarks"
        case .gluons:   return "Gluons"
        case .wBoson:   return "WBoson"
        case .zBoson:   return "ZBoson"
        }
    }

    public var labelWidthSize: CGFloat {
        switch self {
        case .quarks, .electron: return 0.3
        default:                 return 0.1
        }
    }

    public var labelHeightSize: CGFloat {
        switch self {
        case .quarks:   return 0.28
        case .electron: return 0.18
        default:        return 0.105
        }
    }

    public var circleSize: CGFloat {
        switch self {
        case .quarks, .electron: return 0.06
        default:                 return 0.04
        }
    }

    public var isABoson: Bool {
        switch self {
        case .gluons, .photon, .wBoson, .zBoson: return true
        default:                                  return false
        }
    }
}
