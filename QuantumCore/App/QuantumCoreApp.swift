import SwiftUI

#if os(iOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .landscape
    }
}
#endif

@main
struct QuantumCoreApp: App {

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    #if os(visionOS)
    @State private var model = ExperienceModel()
    #endif

    @State private var loader = AssetLoader()

    init() {
        registerFont(named: "VT323-Regular.ttf")
        registerFont(named: "PressStart2P-Regular.ttf")
        registerFont(named: "PixelifySans-Bold.ttf")
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            Group {
                if loader.isLoaded {
                    StartView()
                        .environment(loader)
                        #if os(visionOS)
                        .environment(model)
                        #endif
                } else {
                    LoadingView()
                }
            }
            .task {
                await loader.loadAllAssets()
            }
        }
        #if os(visionOS)
        .defaultSize(CGSize(width: 960, height: 720))
        #endif

        #if os(visionOS)
        ImmersiveSpace(id: "AtomSpace") {
            AtomImmersiveView()
                .environment(loader)
                .environment(model)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        #endif
    }
}
