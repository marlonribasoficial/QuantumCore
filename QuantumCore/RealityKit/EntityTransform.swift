//
//  EntityTransform.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 18/02/26.
//

import RealityKit

extension Entity {
    
    func slideOut(deltaX: Float, deltaY: Float, deltaZ: Float) {
        let pos = self.position
        
        let newPosition = SIMD3<Float>(
            pos.x + deltaX,
            pos.y + deltaY,
            pos.z + deltaZ
        )
        
        self.move(
            to: Transform(translation: newPosition),
            relativeTo: self.parent,
            duration: 2,
            timingFunction: .easeInOut
        )
    }
}
