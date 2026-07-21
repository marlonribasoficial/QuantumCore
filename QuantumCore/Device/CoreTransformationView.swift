//
//  CoreTransformationView.swift
//  QuantumCore
//
//  Sequência do clímax, tocada assim que o feedback do bóson Z termina e
//  antes do "QUANTUM CORE ONLINE":
//
//    1. O Quantum Core todo colorido (6 sistemas acesos) em cena.
//    2. Um surto de luz — e ele se transforma no núcleo laranja
//       (discos/anéis concêntricos, referência quantum-core imagem 1).
//    3. A forma laranja assenta, com morph de raios e cores, na forma
//       clara (referência imagem 2).
//
//  A duração total é coordenada com o DeviceScreenViewModel, que troca o
//  overlay para o texto ONLINE quando a sequência termina.
//

import SwiftUI

struct CoreTransformationView: View {

    /// 0 = colorido · 1 = núcleo laranja · 2 = forma clara.
    @State private var stage = 0
    @State private var flash: Double = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) * 0.85

            ZStack {
                if stage == 0 {
                    QuantumCoreView(litCount: 6, sweep: .none)
                        .frame(width: size, height: size)
                        .transition(.opacity)
                }

                if stage >= 1 {
                    ConcentricCore(pale: stage == 2)
                        .frame(width: size, height: size)
                        .transition(.opacity.combined(with: .scale(scale: 1.06)))
                }

                // Surto de luz na virada colorido → laranja.
                Circle()
                    .fill(.white)
                    .frame(width: size, height: size)
                    .blur(radius: size * 0.06)
                    .opacity(flash)
                    .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear { runSequence() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantum Core fully restored")
    }

    private func runSequence() {
        Task { @MainActor in
            // 1) Core todo colorido em cena.
            try? await Task.sleep(for: .seconds(1.0))

            // 2) Surto de energia + transformação no núcleo laranja.
            withAnimation(.easeIn(duration: 0.3)) { flash = 0.35 }
            withAnimation(.easeInOut(duration: 1.0)) { stage = 1 }
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) { flash = 0 }

            try? await Task.sleep(for: .seconds(2.0))

            // 3) Morph para a forma clara.
            withAnimation(.easeInOut(duration: 1.0)) { stage = 2 }
        }
    }
}

#Preview("Transformação do clímax") {
    CoreTransformationView()
        .frame(width: 500, height: 320)
        .background(Color(hex: 0x0A0B0F))
}
