//
//  AssetLoader.swift
//  SubatomicExperience
//
//  Created by Marlon Ribas on 21/02/26.
//

import SwiftUI
import RealityKit
import QuantumScenes

@MainActor
@Observable
final class AssetLoader {

    var isLoaded = false

    // Entidades são carregadas uma vez e nunca mudam — @ObservationIgnored
    // evita que o macro tente observar Entity! (tipo externo do RealityKit).
    @ObservationIgnored var background: Entity!
    @ObservationIgnored var atom: Entity!
    @ObservationIgnored var electron: Entity!
    @ObservationIgnored var photon: Entity!
    @ObservationIgnored var nucleon: Entity!
    @ObservationIgnored var wBoson: Entity!
    @ObservationIgnored var particles: Entity!
    @ObservationIgnored var zBoson: Entity!

    // Cenas do RCP usadas nos cards de partícula (ParticlePanel).
    // Elétron e fóton reaproveitam `electron`/`photon` (mesmas cenas do átomo).
    @ObservationIgnored var quarksScene: Entity!
    @ObservationIgnored var gluonScene: Entity!
    @ObservationIgnored var bosonWScene: Entity!
    @ObservationIgnored var bosonZScene: Entity!
    
    func loadAllAssets() async {
        do {
            async let background = Entity(named: "Background")

            // Cena do RCP (pacote QuantumScenes); as demais ainda vêm dos .usdz do Resources.
            // Cenas em subpastas do .rkassets são endereçadas como "Pasta/Cena".
            async let atom = Entity(named: "Atomo/Atomo", in: quantumScenesBundle)

            async let electron = Entity(named: "Eletron/Eletron", in: quantumScenesBundle)
            async let photon = Entity(named: "Foton/Foton", in: quantumScenesBundle)
            async let nucleon = Entity(named: "Nucleon/Nucleon", in: quantumScenesBundle)

            async let wBoson = Entity(named: "wBoson")
            async let particles = Entity(named: "Particles")
            async let zBoson = Entity(named: "zBoson")

            // Cenas do RCP para os cards
            async let quarksScene = Entity(named: "Quarks/Quarks", in: quantumScenesBundle)
            async let gluonScene = Entity(named: "Gluon/Gluon", in: quantumScenesBundle)
            async let bosonWScene = Entity(named: "BosonW/BosonW", in: quantumScenesBundle)
            async let bosonZScene = Entity(named: "BosonZ/BosonZ", in: quantumScenesBundle)

            self.background = try await background
            self.atom = try await atom
            self.electron = try await electron
            self.photon = try await photon
            self.nucleon = try await nucleon
            self.wBoson = try await wBoson
            self.particles = try await particles
            self.zBoson = try await zBoson
            self.quarksScene = try await quarksScene
            self.gluonScene = try await gluonScene
            self.bosonWScene = try await bosonWScene
            self.bosonZScene = try await bosonZScene

            isLoaded = true
            
        } catch {
            print("Erro ao carregar assets:", error)
        }
    }
}
