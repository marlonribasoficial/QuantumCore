//
//  EntityDescendant.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 18/02/26.
//

import RealityKit

extension Entity {
    func isDescendant(of ancestor: Entity) -> Bool {
        if self == ancestor { return true }
        var current = parent
        while let node = current {
            if node == ancestor { return true }
            current = node.parent
        }
        return false
    }
}
