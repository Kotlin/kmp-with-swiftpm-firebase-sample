package org.jetbrains.kotlin.firebase.sample.samples

import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FAIBChat
import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FAIBGenerativeModel
import org.jetbrains.kotlin.firebase.sample.KMPError
import org.jetbrains.kotlin.firebase.sample.toKMPError

/**
 * Sample demonstrating Firebase AI Logic (Gemini) from Kotlin.
 *
 * FirebaseAILogic is a pure-Swift SDK, so it is consumed through the local
 * `FirebaseAIBridge` Swift package, which re-exposes the APIs with `@objc`.
 * Swift `async throws` methods arrive in Kotlin as completion-handler callbacks.
 */
@Suppress("UNUSED")
object AISample {

    private val model by lazy {
        FAIBGenerativeModel(
            modelName = "gemini-2.5-flash",
            systemInstruction = "You are a concise assistant inside a Kotlin Multiplatform sample app.",
        )
    }

    /**
     * Generate a text response for a single prompt.
     */
    fun generateText(prompt: String, completion: (String?, KMPError?) -> Unit) {
        model.generateContent(prompt) { text, error ->
            if (error != null) {
                completion(null, error.toKMPError())
            } else {
                completion(text, null)
            }
        }
    }

    /**
     * Count the tokens a prompt would consume.
     */
    fun countTokens(prompt: String, completion: (Long?, KMPError?) -> Unit) {
        model.countTokens(prompt) { tokens, error ->
            if (error != null) {
                completion(null, error.toKMPError())
            } else {
                completion(tokens, null)
            }
        }
    }

    /**
     * Start a multi-turn chat; the returned chat keeps the conversation history.
     */
    fun startChat(): FAIBChat = model.startChat()

    /**
     * Send a message within a chat started by [startChat].
     */
    fun sendMessage(chat: FAIBChat, message: String, completion: (String?, KMPError?) -> Unit) {
        chat.sendMessage(message) { reply, error ->
            if (error != null) {
                completion(null, error.toKMPError())
            } else {
                completion(reply, null)
            }
        }
    }
}
