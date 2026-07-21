import SwiftUI
import Core

@MainActor
struct ExperienceRoot: View {

    // MARK: - visionOS: estado vive em ExperienceModel (environment)
    #if os(visionOS)

    @Environment(ExperienceModel.self) var model
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismiss) var dismiss

    var body: some View {
        @Bindable var model = model
        DeviceScreen(
            selectedTab: $model.selectedTab,
            coreEnergy: $model.coreEnergy,
            homeOverlay: $model.homeOverlay,
            mode: model.deviceMode,
            onIntroFinished: {
                model.canPlay = true
                model.showDevice = false
            },
            onEndingFinished: {
                model.reset()
                Task { await dismissImmersiveSpace() }
                dismiss()
            }
        )
        .onChange(of: model.showDevice) { _, show in
            if !show { dismissWindow(id: "main") }
        }
    }

    // MARK: - iOS/iPadOS: estado local, AtomView e DeviceScreen em ZStack
    #else

    @State private var selectedTab: DeviceTab = .home
    @State private var coreEnergy: Int = 0
    @State private var showDevice = true
    @State var canPlay: Bool = false
    @State private var deviceMode: DeviceMode = .intro
    @State var homeOverlay: HomeOverlay = .animationIntro

    @Environment(\.dismiss) private var dismiss

    // Clamp aplicado no setter — elimina o need de onChange reativo
    private var clampedEnergy: Binding<Int> {
        Binding(
            get: { coreEnergy },
            set: { coreEnergy = min(max($0, 0), 100) }
        )
    }

    var body: some View {
        ZStack {
            AtomView(
                coreEnergy: clampedEnergy,
                canPlay: $canPlay,
                onZBosonFinished: {
                    homeOverlay = .robot
                    deviceMode = .ending
                    showDevice = true
                }
            )

            if showDevice {
                DeviceScreen(
                    selectedTab: $selectedTab,
                    coreEnergy: clampedEnergy,
                    homeOverlay: $homeOverlay,
                    mode: deviceMode,
                    onIntroFinished: {
                        hideDevice()
                        canPlay = true
                    },
                    onEndingFinished: {
                        dismiss()
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.8, dampingFraction: 0.9), value: showDevice)
    }

    func hideDevice() {
        showDevice = false
    }
    #endif
}
