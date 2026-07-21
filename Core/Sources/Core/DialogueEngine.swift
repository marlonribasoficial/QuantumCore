public struct DialogueSequence {
    public let id: String
    public let messages: [String]
    public let onFinish: (() -> Void)?
    /// Se true, a última mensagem exibe o botão "LOOK INSIDE" (call to action).
    public let cta: Bool

    public init(id: String, messages: [String], cta: Bool = false, onFinish: (() -> Void)? = nil) {
        self.id = id
        self.messages = messages
        self.cta = cta
        self.onFinish = onFinish
    }
}

public struct DialogueEngine {
    private var currentSequence: DialogueSequence?
    private var currentIndex: Int = 0

    public var isShowingDialogue: Bool = false
    public var currentText: String = ""
    /// true quando a mensagem atual é a última de uma sequência marcada como CTA.
    public var isCTA: Bool = false

    public init() {}

    public mutating func start(sequence: DialogueSequence) {
        currentSequence = sequence
        currentIndex = 0
        currentText = sequence.messages.first ?? ""
        isShowingDialogue = true
        updateCTA()
    }

    private mutating func updateCTA() {
        guard let sequence = currentSequence else { isCTA = false; return }
        isCTA = sequence.cta && currentIndex == sequence.messages.count - 1
    }

    /// Avança para a próxima mensagem.
    /// Retorna o closure onFinish se o diálogo terminou, nil se ainda há mensagens.
    /// O chamador é responsável por executar o closure APÓS a mutação terminar.
    public mutating func next() -> (() -> Void)? {
        guard let sequence = currentSequence else { return nil }

        currentIndex += 1

        if currentIndex < sequence.messages.count {
            currentText = sequence.messages[currentIndex]
            updateCTA()
            return nil
        } else {
            return finish()
        }
    }

    /// Termina o diálogo e retorna o closure onFinish sem chamá-lo.
    /// O chamador é responsável por executar o closure APÓS a mutação terminar.
    @discardableResult
    public mutating func finish() -> (() -> Void)? {
        let completion = currentSequence?.onFinish
        currentSequence = nil
        currentIndex = 0
        isShowingDialogue = false
        currentText = ""
        isCTA = false
        return completion
    }
}
