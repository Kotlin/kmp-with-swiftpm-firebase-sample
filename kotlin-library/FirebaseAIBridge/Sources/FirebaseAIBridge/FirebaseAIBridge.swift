import Foundation
import FirebaseAILogic

/// Objective-C facade over `FirebaseAILogic.GenerativeModel`.
///
/// `async throws` methods are exported to Objective-C as `completionHandler:` methods,
/// which Kotlin sees as callbacks: `generateContent(prompt) { text, error -> ... }`.
@objc(FAIBGenerativeModel)
public final class GenerativeModelBridge: NSObject, Sendable {
    private let model: GenerativeModel

    /// - Parameters:
    ///   - modelName: A Gemini model name, e.g. `gemini-2.5-flash`.
    ///   - systemInstruction: Optional instructions that steer the model's behavior.
    @objc public init(modelName: String, systemInstruction: String?) {
        model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
            modelName: modelName,
            systemInstruction: systemInstruction.map { ModelContent(role: "system", parts: $0) }
        )
    }

    /// Generates a text response for a single prompt.
    @objc public func generateContent(_ prompt: String) async throws -> String {
        try await model.generateContent(prompt).requireText()
    }

    /// Counts the tokens the prompt would consume.
    @objc public func countTokens(_ prompt: String) async throws -> Int {
        try await model.countTokens(prompt).totalTokens
    }

    /// Starts a multi-turn conversation.
    @objc public func startChat() -> ChatBridge {
        ChatBridge(chat: model.startChat())
    }
}

/// Objective-C facade over `FirebaseAILogic.Chat`; the chat keeps the conversation history.
@objc(FAIBChat)
public final class ChatBridge: NSObject, Sendable {
    private let chat: Chat

    init(chat: Chat) {
        self.chat = chat
    }

    /// Sends a message and returns the model's reply.
    @objc public func sendMessage(_ message: String) async throws -> String {
        try await chat.sendMessage(message).requireText()
    }
}

/// Reaches Kotlin as an `NSError` with this description.
enum BridgeError: LocalizedError {
    case noText

    var errorDescription: String? {
        switch self {
        case .noText: "The response has no text, for example because a safety filter blocked it."
        }
    }
}

private extension GenerateContentResponse {
    func requireText() throws -> String {
        guard let text else { throw BridgeError.noText }
        return text
    }
}
