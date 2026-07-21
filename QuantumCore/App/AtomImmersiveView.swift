#if os(visionOS)
import SwiftUI
import Core

struct AtomImmersiveView: View {
    @Environment(ExperienceModel.self) var model
    @Environment(\.openWindow) var openWindow

    var body: some View {
        @Bindable var model = model
        AtomView(
            coreEnergy: $model.coreEnergy,
            canPlay: $model.canPlay,
            onZBosonFinished: {
                model.homeOverlay = .robot
                model.deviceMode = .ending
                model.showDevice = true
            }
        )
        .onChange(of: model.showDevice) { _, show in
            if show { openWindow(id: "main") }
        }
    }
}
#endif
