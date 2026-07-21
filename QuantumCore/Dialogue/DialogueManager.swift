//
//  DialogueManager.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 17/02/26.
//

import SwiftUI
import Core

@MainActor
@Observable
final class DialogueManager {

    var isShowingDialogue: Bool = false
    var currentText: String = ""
    var currentIsCTA: Bool = false

    private var engine = DialogueEngine()

    func startDialogue(_ sequence: DialogueSequence) {
        engine.start(sequence: sequence)
        currentText = engine.currentText
        currentIsCTA = engine.isCTA
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            isShowingDialogue = engine.isShowingDialogue
        }
    }

    func next() {
        let completion = engine.next()
        currentText = engine.currentText
        currentIsCTA = engine.isCTA
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            isShowingDialogue = engine.isShowingDialogue
        }
        completion?()
    }
}
