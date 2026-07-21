//
//  AboutYouSheet.swift
//  QuantumCore
//
//  Modal "ABOUT YOU" — captura nome + nota do usuário para o Max
//  personalizar a fala depois. Abre pelo botão ABOUT ME da Start Screen.
//

import SwiftUI

struct AboutYouSheet: View {
    /// Fator de escala relativo ao canvas de design (912×421).
    var scale: CGFloat = 1

    let initialName: String
    let initialNote: String
    let onSave: (_ name: String, _ note: String) -> Void
    let onClose: () -> Void

    @State private var name: String = ""
    @State private var note: String = ""
    @FocusState private var focus: Field?

    private enum Field { case name, note }

    var body: some View {
        ZStack {
            // Overlay que escurece a tela; toque fora fecha.
            Color(hex: 0x040508, alpha: 0.72)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onClose() }

            card
                .frame(width: 430 * scale)
                .padding(20 * scale)
        }
        .onAppear {
            name = initialName
            note = initialNote
        }
    }

    // MARK: Card

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabeçalho
            HStack {
                Text("ABOUT YOU")
                    .font(.custom(AppFonts.ui, size: 26 * scale))
                    .tracking(1.3 * scale)
                    .foregroundStyle(StartPalette.accent)
                Spacer()
                Button(action: onClose) {
                    Text("×")
                        .font(.custom(AppFonts.ui, size: 24 * scale))
                        .foregroundStyle(StartPalette.cream.opacity(0.5))
                        .padding(.horizontal, 4 * scale)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.bottom, 4 * scale)

            Text("Max will remember this as you explore.")
                .font(.custom(AppFonts.ui, size: 17 * scale))
                .foregroundStyle(StartPalette.cream.opacity(0.55))
                .padding(.bottom, 16 * scale)

            // Campo 1 — nome
            fieldLabel("WHAT SHOULD I CALL YOU?")
            inputBox {
                ZStack(alignment: .leading) {
                    if name.isEmpty {
                        Text("Your name")
                            .font(.custom(AppFonts.ui, size: 20 * scale))
                            .foregroundStyle(StartPalette.cream.opacity(0.35))
                    }
                    TextField("", text: $name)
                        .textFieldStyle(.plain)
                        .font(.custom(AppFonts.ui, size: 20 * scale))
                        .foregroundStyle(StartPalette.cream)
                        .tint(StartPalette.accent)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .note }
                }
            }
            .padding(.bottom, 15 * scale)

            // Campo 2 — nota
            fieldLabel("TELL ME SOMETHING ABOUT YOU")
            inputBox {
                ZStack(alignment: .topLeading) {
                    if note.isEmpty {
                        Text("Age, what you're curious about, anything...")
                            .font(.custom(AppFonts.ui, size: 19 * scale))
                            .foregroundStyle(StartPalette.cream.opacity(0.35))
                            .padding(.top, 2 * scale)
                    }
                    TextEditor(text: $note)
                        .font(.custom(AppFonts.ui, size: 19 * scale))
                        .foregroundStyle(StartPalette.cream)
                        .tint(StartPalette.accent)
                        .scrollContentBackground(.hidden)
                        .frame(height: 74 * scale)
                        .focused($focus, equals: .note)
                }
            }
            .padding(.bottom, 18 * scale)

            // Botão SAVE
            Button {
                onSave(name.trimmingCharacters(in: .whitespacesAndNewlines),
                       note.trimmingCharacters(in: .whitespacesAndNewlines))
            } label: {
                Text("SAVE")
                    .font(.custom(AppFonts.ui, size: 22 * scale))
                    .tracking(1.1 * scale)
                    .foregroundStyle(StartPalette.screenBase)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                            .fill(StartPalette.accent)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save")
        }
        .padding(.horizontal, 24 * scale)
        .padding(.top, 22 * scale)
        .padding(.bottom, 24 * scale)
        .background(
            RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [StartPalette.cardTop, StartPalette.screenBase],
                        center: .top,
                        startRadius: 0,
                        endRadius: 430 * scale * 0.85
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                        .stroke(StartPalette.accent.opacity(0.32), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.6), radius: 30 * scale, x: 0, y: 20 * scale)
    }

    // MARK: Peças reutilizáveis

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.custom(AppFonts.ui, size: 16 * scale))
            .tracking(1.1 * scale)
            .foregroundStyle(StartPalette.cream.opacity(0.45))
            .padding(.bottom, 5 * scale)
    }

    private func inputBox<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 12 * scale)
            .padding(.vertical, 9 * scale)
            .background(
                RoundedRectangle(cornerRadius: 9 * scale, style: .continuous)
                    .fill(StartPalette.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9 * scale, style: .continuous)
                            .stroke(StartPalette.cream.opacity(0.18), lineWidth: 1)
                    )
            )
    }
}
