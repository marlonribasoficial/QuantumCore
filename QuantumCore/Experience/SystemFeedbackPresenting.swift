import SwiftUI
import Core

/// Comportamento compartilhado do feedback de sistema (creditar energia → exibir o
/// modal pulsante por um tempo → esconder) entre `AtomViewModel` e `NucleusViewModel`.
///
/// A transição de estado que ocorre *após* o feedback é específica de cada ViewModel
/// (um detém `experienceState` diretamente, o outro propaga via callback), por isso
/// fica a cargo do closure `after`.
@MainActor
protocol SystemFeedbackPresenting: AnyObject {
    var showSystemFeedback: Bool { get set }
    var feedbackType: OverlayType? { get set }
    var onEnergyGained: (() -> Void)? { get set }
}

@MainActor
extension SystemFeedbackPresenting {
    /// Credita energia, anima o modal de feedback por `duration` segundos e então
    /// executa `after` — a transição de estado própria de cada ViewModel.
    func runSystemFeedback(
        type: OverlayType,
        duration: Double = 4.0,
        after: @escaping @MainActor () -> Void
    ) {
        onEnergyGained?()
        feedbackType = type

        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            showSystemFeedback = true
        }

        Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(duration))

            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                self.showSystemFeedback = false
            }

            after()
        }
    }
}
