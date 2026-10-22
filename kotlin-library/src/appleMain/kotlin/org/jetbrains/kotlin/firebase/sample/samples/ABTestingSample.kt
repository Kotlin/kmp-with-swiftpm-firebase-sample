package org.jetbrains.kotlin.firebase.sample.samples

import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRRemoteConfig
import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRRemoteConfigSettings
import org.jetbrains.kotlin.firebase.sample.KMPError
import org.jetbrains.kotlin.firebase.sample.toKMPError

/**
 * Sample demonstrating Firebase A/B Testing.
 *
 * Experiments are defined in the Firebase console and reach the app as Remote Config
 * parameters, so the client reads a variant like any other Remote Config value.
 * FirebaseRemoteConfig already depends on FirebaseABTesting, which tracks experiment exposure.
 */
@Suppress("UNUSED")
object ABTestingSample {

    private val remoteConfig: FIRRemoteConfig
        get() = FIRRemoteConfig.remoteConfig()

    /**
     * Set up Remote Config with a short fetch interval for testing experiments.
     */
    fun configureForExperiments() {
        val settings = FIRRemoteConfigSettings()
        settings.setMinimumFetchInterval(0.0) // No throttle for testing
        remoteConfig.setConfigSettings(settings)
    }

    /**
     * Fetch and activate experiment parameters.
     */
    fun fetchExperimentConfig(completion: (KMPError?) -> Unit) {
        remoteConfig.fetchAndActivateWithCompletionHandler { _, error ->
            if (error != null) {
                completion(error.toKMPError())
            } else {
                completion(null)
            }
        }
    }

    /**
     * Get the experiment variant for a given experiment key.
     * Returns the variant string (e.g. "control", "variant_a", "variant_b").
     */
    fun getExperimentVariant(experimentKey: String): String {
        return remoteConfig.configValueForKey(experimentKey).stringValue().ifEmpty { "control" }
    }

    /**
     * Check if a feature flag from an A/B test is enabled.
     */
    fun isFeatureEnabled(featureKey: String): Boolean {
        return remoteConfig.configValueForKey(featureKey).boolValue()
    }

    /**
     * Run the callback for the current variant. Unknown variants fall back to [onControl].
     */
    fun applyExperiment(
        experimentKey: String,
        onControl: () -> Unit,
        onVariantA: () -> Unit,
        onVariantB: () -> Unit
    ) {
        when (getExperimentVariant(experimentKey)) {
            "control" -> onControl()
            "variant_a" -> onVariantA()
            "variant_b" -> onVariantB()
            else -> onControl()
        }
    }
}
