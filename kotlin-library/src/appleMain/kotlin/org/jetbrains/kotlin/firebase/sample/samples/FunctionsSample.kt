package org.jetbrains.kotlin.firebase.sample.samples

import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRFunctions
import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRHTTPSCallableOptions
import org.jetbrains.kotlin.firebase.sample.KMPError
import org.jetbrains.kotlin.firebase.sample.complete

/**
 * Sample demonstrating Firebase Cloud Functions:
 * calling HTTPS callable functions deployed to your Firebase project.
 *
 * FirebaseFunctions is implemented in Swift, but its public API is annotated
 * with `@objc`, so it is imported into Kotlin directly (no wrapper package needed).
 */
@Suppress("UNUSED")
object FunctionsSample {

    private val functions: FIRFunctions
        get() = FIRFunctions.functions()

    /**
     * Call a callable function by name.
     * [data] must be encodable as JSON: String, Number, Boolean, List or Map.
     */
    fun call(name: String, data: Any?, completion: (Any?, KMPError?) -> Unit) {
        functions.HTTPSCallableWithName(name).callWithObject(data) { result, error ->
            completion.complete(result?.data(), error)
        }
    }

    /**
     * Call a callable function in a specific region (e.g. "europe-west1").
     */
    fun callInRegion(region: String, name: String, data: Any?, completion: (Any?, KMPError?) -> Unit) {
        FIRFunctions.functionsForRegion(region).HTTPSCallableWithName(name).callWithObject(data) { result, error ->
            completion.complete(result?.data(), error)
        }
    }

    /**
     * Call a function protected with App Check replay protection,
     * which requires limited-use App Check tokens.
     */
    fun callWithLimitedUseAppCheckToken(name: String, data: Any?, completion: (Any?, KMPError?) -> Unit) {
        val options = FIRHTTPSCallableOptions(requireLimitedUseAppCheckTokens = true)
        functions.HTTPSCallableWithName(name, options).callWithObject(data) { result, error ->
            completion.complete(result?.data(), error)
        }
    }
}
