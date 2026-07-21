#if os(visionOS)
import SwiftUI
import Core

@MainActor
@Observable
final class ExperienceModel {
    var coreEnergy: Int = 0 {
        didSet { coreEnergy = min(max(coreEnergy, 0), 100) }
    }
    var canPlay: Bool = false
    var deviceMode: DeviceMode = .intro
    var homeOverlay: HomeOverlay = .animationIntro
    var selectedTab: DeviceTab = .home
    var showDevice: Bool = true

    func reset() {
        coreEnergy = 0
        canPlay = false
        deviceMode = .intro
        homeOverlay = .animationIntro
        selectedTab = .home
        showDevice = true
    }
}
#endif
