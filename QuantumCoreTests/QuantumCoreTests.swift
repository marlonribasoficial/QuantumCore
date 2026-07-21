//
//  QuantumCoreTests.swift
//  QuantumCoreTests
//
//  Created by Marlon Ribas on 13/06/26.
//

import Testing
import Core

// MARK: - DialogueEngine

@Suite("DialogueEngine")
struct DialogueEngineTests {

    @Test func startSetsFirstMessage() {
        var engine = DialogueEngine()
        engine.start(sequence: DialogueSequence(id: "t1", messages: ["Hello", "World"]))
        #expect(engine.isShowingDialogue == true)
        #expect(engine.currentText == "Hello")
    }

    @Test func nextAdvancesToSecondMessage() {
        var engine = DialogueEngine()
        engine.start(sequence: DialogueSequence(id: "t2", messages: ["A", "B", "C"]))
        let result = engine.next()
        #expect(result == nil)
        #expect(engine.currentText == "B")
        #expect(engine.isShowingDialogue == true)
    }

    @Test func nextAfterLastMessageReturnsOnFinish() {
        var engine = DialogueEngine()
        var finished = false
        engine.start(sequence: DialogueSequence(id: "t3", messages: ["Only"]) {
            finished = true
        })
        let completion = engine.next()
        completion?()
        #expect(finished == true)
        #expect(engine.isShowingDialogue == false)
    }

    @Test func finishClearsState() {
        var engine = DialogueEngine()
        engine.start(sequence: DialogueSequence(id: "t4", messages: ["X"]))
        engine.finish()
        #expect(engine.isShowingDialogue == false)
        #expect(engine.currentText == "")
    }

    @Test func startingNewSequenceReplacesOld() {
        var engine = DialogueEngine()
        engine.start(sequence: DialogueSequence(id: "first", messages: ["First"]))
        engine.start(sequence: DialogueSequence(id: "second", messages: ["Second", "Third"]))
        #expect(engine.currentText == "Second")
    }
}

// MARK: - ExperienceState

@Suite("ExperienceState.interactionConfiguration")
struct ExperienceStateTests {

    @Test func introBlocksAllInteractions() {
        let config = ExperienceState.intro.interactionConfiguration
        #expect(config.canZoom == false)
        #expect(config.canRotate == false)
        #expect(config.canInteractWithShell == false)
        #expect(config.canInteractWithElectron == false)
    }

    @Test func exploringAllowsZoomAndRotate() {
        let config = ExperienceState.exploring.interactionConfiguration
        #expect(config.canZoom == true)
        #expect(config.canRotate == true)
    }

    @Test func shellDiscoveredAllowsShellInteraction() {
        let config = ExperienceState.shellDiscovered.interactionConfiguration
        #expect(config.canInteractWithShell == true)
    }

    @Test func electronInteractedDisablesElectronInteraction() {
        let config = ExperienceState.electronInteracted.interactionConfiguration
        #expect(config.canInteractWithElectron == false)
    }
}
