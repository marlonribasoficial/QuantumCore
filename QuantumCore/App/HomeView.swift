import SwiftUI
import RealityKit

struct HomeView: View {

    @Environment(AssetLoader.self) var loader
    @State private var playGame = false

    #if os(visionOS)
    @Environment(ExperienceModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    #endif

    var body: some View {
        NavigationStack {
            ZStack {
                RealityView { content in
                    let background = loader.background.clone(recursive: true)
                    background.scale = .one * 0.06
                    content.add(background)
                    if let animation = background.availableAnimations.first {
                        background.playAnimation(animation.repeat())
                    }
                }
                .blur(radius: 4)
                .accessibilityHidden(true)

                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        ZStack {
                            Text("Quantum")
                                .font(.custom("PressStart2P-Regular", size: 104))
                                .foregroundColor(.black)
                                .offset(x: 6, y: 4)
                                .accessibilityHidden(true)

                            Text("Quantum")
                                .font(.custom("PressStart2P-Regular", size: 104))
                                .foregroundColor(AppColors.tertiary)
                                .accessibilityHidden(true)
                        }

                        ZStack {
                            Text("Core")
                                .font(.custom("PressStart2P-Regular", size: 104))
                                .foregroundColor(.black)
                                .offset(x: 6, y: 4)
                                .accessibilityHidden(true)

                            Text("Core")
                                .font(.custom("PressStart2P-Regular", size: 104))
                                .foregroundColor(AppColors.tertiary)
                                .accessibilityHidden(true)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Quantum Core")
                    .accessibilityAddTraits(.isHeader)

                    Button {
                        playGame = true
                        #if os(visionOS)
                        Task { await openImmersiveSpace(id: "AtomSpace") }
                        #endif
                    } label: {
                        Text("Play")
                            .font(.custom("PressStart2P-Regular", size: 36))
                            .foregroundStyle(.black)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 128)
                            .background(
                                RoundedRectangle(cornerRadius: 64)
                                    .fill(AppColors.primary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 64)
                                    .stroke(.black, lineWidth: 8)
                            )
                    }
                    .buttonStyle(.plain)
                    .hoverEffect()
                    .accessibilityLabel("Start experience")
                    .accessibilityHint("Double tap to begin the experience")
                }
            }
            .navigationDestination(isPresented: $playGame) {
                ExperienceRoot()
            }
            .onChange(of: playGame) { _, newValue in
                if newValue {
                    AccessibilityNotification.ScreenChanged().post()
                }
            }
            .background(.black)
            .ignoresSafeArea()
        }
    }
}
