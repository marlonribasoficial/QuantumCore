import SwiftUI
import Core

extension OverlayType {
    /// Cor de identidade da partícula (valores exatos do protótipo).
    var color: Color {
        switch self {
        case .electron: return Color(hex: 0x00E23F)
        case .photon:   return Color(hex: 0xFFD84D)
        case .quarks:   return Color(hex: 0x8B5CF6)
        case .gluons:   return Color(hex: 0xC4CAD2)
        case .wBoson:   return Color(hex: 0x22D3EE)
        case .zBoson:   return Color(hex: 0x5B82FF)
        }
    }
}
