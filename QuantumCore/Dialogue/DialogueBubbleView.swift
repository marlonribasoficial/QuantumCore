//
//  DialogueBubbleView.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 17/02/26.
//

import SwiftUI
import Core

struct DialogueBubbleView: View {
    
    var manager: DialogueManager
    
    let type: OverlayType?
    
    var body: some View {
        if manager.isShowingDialogue {
            
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    if let type {
                        ParticlePanel(type: type)
                            .padding(.horizontal, AppLayout.cardPadding)
                            .padding(.top, AppLayout.cardPadding)
                            // Reserva a faixa da caixa de diálogo na base.
                            .padding(.bottom, 120)
                    } else {
                        Spacer()
                    }
                }
                
                DialogueBox(
                    text: manager.currentText,
                    isCTA: manager.currentIsCTA,
                    action: { manager.next() }
                )
            }
            .ignoresSafeArea()
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom),
                    removal: .move(edge: .bottom)
                )
            )
            .zIndex(10)
        }
    }
}

