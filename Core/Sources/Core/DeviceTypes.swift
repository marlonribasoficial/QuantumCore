public enum DeviceTab: Sendable {
    case home
    case system
}

public enum IntroPhase: Sendable {
    case idle
    case intro
    case whatHappened
    case systems
    case atom
    case callToAction
    case finished
}

public enum DeviceMode: Sendable {
    case intro
    case ending
}

public enum HomeOverlay: Sendable {
    case animationIntro
    case robot
    /// Clímax: o Quantum Core colorido se transforma no núcleo laranja e
    /// depois assenta na forma clara, antes do "QUANTUM CORE ONLINE".
    case coreTransformation
    case animationEnding
}
