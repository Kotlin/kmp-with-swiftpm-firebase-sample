package org.jetbrains.kotlin.firebase.sample

/**
 * Error domain, such as `NSURLErrorDomain` on Apple platforms.
 */
typealias KMPErrorDomain = String

/**
 * Platform-independent error. On Apple platforms it wraps an `NSError`.
 */
@Suppress("UNUSED")
expect class KMPError {
    /**
     * The domain of the error. For example, "NSURLErrorDomain" or a custom domain.
     */
    val domain: KMPErrorDomain?

    /**
     * The error code.
     */
    val code: Int

    /**
     * Additional information about the error. Keys are `Any?` because `NSError.userInfo` keys are not always strings.
     */
    val userInfo: Map<Any?, *>

    /**
     * A localized, user-readable description of the error.
     */
    val localizedDescription: String
}