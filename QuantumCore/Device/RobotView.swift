//
//  RobotView.swift
//  QuantumCore
//
//  Max no centro da tela do dispositivo — rosto em matriz de pontos
//  (MaxFaceView), aceso quando o núcleo está online.
//

import SwiftUI

struct RobotView: View {
    var lit: Bool = false

    var body: some View {
        GeometryReader { geometry in
            MaxFaceView(lit: lit)
                .frame(
                    width: geometry.size.width * 0.7,
                    height: geometry.size.height * 0.92
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
