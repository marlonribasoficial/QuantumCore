//
//  HomePanel.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 08/02/26.
//

import SwiftUI
import Core

struct HomePanel: View {
    
    @Binding var coreEnergy: Int
    var homeOverlay: HomeOverlay

    var body: some View {
        VStack {
            Spacer()

            Group {
                switch homeOverlay {
                case .animationIntro:
                    SystemOfflineView()
                case .robot:
                    RobotView(lit: coreEnergy >= 100)
                case .coreTransformation:
                    CoreTransformationView()
                case .animationEnding:
                    SystemOnlineView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.4), value: homeOverlay)

            Spacer()
        }
    }
}
