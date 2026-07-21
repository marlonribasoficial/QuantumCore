public struct InteractionState: Sendable {
    public var canRotate: Bool = true
    public var canZoom: Bool = true
    public var canInteractWithShell: Bool = false
    public var canInteractWithNucleus: Bool = false
    public var canInteractWithElectron: Bool = false
    public var canInteractWithPhoton: Bool = false
    public var canInteractWithQuarks: Bool = false
    public var canInteractWithGluons: Bool = false
    public var canInteractWithWBoson: Bool = false
    public var canInteractWithZBoson: Bool = false

    public init(
        canRotate: Bool = true,
        canZoom: Bool = true,
        canInteractWithShell: Bool = false,
        canInteractWithNucleus: Bool = false,
        canInteractWithElectron: Bool = false,
        canInteractWithPhoton: Bool = false,
        canInteractWithQuarks: Bool = false,
        canInteractWithGluons: Bool = false,
        canInteractWithWBoson: Bool = false,
        canInteractWithZBoson: Bool = false
    ) {
        self.canRotate = canRotate
        self.canZoom = canZoom
        self.canInteractWithShell = canInteractWithShell
        self.canInteractWithNucleus = canInteractWithNucleus
        self.canInteractWithElectron = canInteractWithElectron
        self.canInteractWithPhoton = canInteractWithPhoton
        self.canInteractWithQuarks = canInteractWithQuarks
        self.canInteractWithGluons = canInteractWithGluons
        self.canInteractWithWBoson = canInteractWithWBoson
        self.canInteractWithZBoson = canInteractWithZBoson
    }
}
