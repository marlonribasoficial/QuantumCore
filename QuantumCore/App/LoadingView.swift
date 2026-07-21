//
//  LoadingView.swift
//  QuantumCore
//
//  Tela de carregamento dos assets 3D, na paleta do protótipo.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            StartPalette.screenBase
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(StartPalette.accent)
                    .scaleEffect(1.5)

                Text("Loading...")
                    .font(.custom(AppFonts.ui, size: 40))
                    .foregroundStyle(StartPalette.cream)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Loading")
            .accessibilityHint("Please wait")
            .accessibilityAddTraits(.isStaticText)
        }
    }
}
