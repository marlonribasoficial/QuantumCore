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
    @ObservationIgnored var electronPulsing: Entity!
    @ObservationIgnored var photon: Entity!
    @ObservationIgnored var photonPulsing: Entity!
    @ObservationIgnored var protonQuarks: Entity!
    @ObservationIgnored var quarksPulsing: Entity!
    @ObservationIgnored var gluonsPulsing: Entity!
    @ObservationIgnored var wBoson: Entity!
    @ObservationIgnored var wBosonPulsing: Entity!
    @ObservationIgnored var particles: Entity!
    @ObservationIgnored var zBoson: Entity!
    @ObservationIgnored var zBosonPulsing: Entity!
    
    func loadAllAssets() async {
        do {
            async let background = Entity(named: "Background")

            // Cena do RCP (pacote QuantumScenes); as demais ainda vêm dos .usdz do Resources.
            // Cenas em subpastas do .rkassets são endereçadas como "Pasta/Cena".
            async let atom = Entity(named: "Atomo/Atomo", in: quantumScenesBundle)

            async let electron = Entity(named: "Eletron/Eletron", in: quantumScenesBundle)
            async let electronPulsing = Entity(named: "ElectronPulsing")

            async let photon = Entity(named: "Foton/Foton", in: quantumScenesBundle)
            async let photonPulsing = Entity(named: "PhotonPulsing")
            
            async let protonQuarks = Entity(named: "ProtonQuarks")
            async let quarksPulsing = Entity(named: "QuarksPulsing")

            async let gluonsPulsing = Entity(named: "GluonPulsing")
            
            async let wBoson = Entity(named: "wBoson")
            async let wBosonPulsing = Entity(named: "wBosonPulsing")
            
            async let particles = Entity(named: "Particles")
            async let zBoson = Entity(named: "zBoson")
            async let zBosonPulsing = Entity(named: "zBosonPulsing")

            self.background = try await background
            self.atom = try await atom
            self.electron = try await electron
            self.electronPulsing = try await electronPulsing
            self.photon = try await photon
            self.photonPulsing = try await photonPulsing
            self.protonQuarks = try await protonQuarks
            self.quarksPulsing = try await quarksPulsing
            self.gluonsPulsing = try await gluonsPulsing
            self.wBoson = try await wBoson
            self.wBosonPulsing = try await wBosonPulsing
            self.particles = try await particles
            self.zBoson = try await zBoson
            self.zBosonPulsing = try await zBosonPulsing
            
            isLoaded = true
            
        } catch {
            print("Erro ao carregar assets:", error)
        }
    }
}
