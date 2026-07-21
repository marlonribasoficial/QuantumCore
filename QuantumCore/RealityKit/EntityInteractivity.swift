//
//  EntityInteractivity.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 18/02/26.
//

import RealityKit

extension Entity {
    
    func setInteractivity(enabled: Bool) {
        if enabled {
            components.set(InputTargetComponent())
            generateCollisionShapes(recursive: true)
            #if os(visionOS)
            components.set(HoverEffectComponent())
            #endif
        } else {
            components.remove(InputTargetComponent.self)
            components.remove(CollisionComponent.self)
            #if os(visionOS)
            components.remove(HoverEffectComponent.self)
            #endif
        }
    }
    
    func enableCollision() {
        generateCollisionShapes(recursive: true)
    }
}
