//
//  SystemPanel.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 08/02/26.
//

import SwiftUI

struct SystemPanel: View {
    var isOffline: Bool

    var body: some View {
        CoreChamberView(online: !isOffline)
            .padding(24)
    }
}
