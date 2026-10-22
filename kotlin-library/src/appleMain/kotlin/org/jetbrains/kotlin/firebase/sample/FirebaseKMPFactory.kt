package org.jetbrains.kotlin.firebase.sample

/**
 * Creates [FirebaseKMP] instances for the Swift app.
 */
@Suppress("UNUSED")
object FirebaseKMPFactory {
    /**
     * Returns the implementation backed by the Firebase Apple SDK.
     */
    fun firebase(): FirebaseKMP = FirebaseKMPImpl()

    /**
     * Returns a [MockFirebaseKMP] that never calls Firebase, for tests and SwiftUI previews.
     */
    fun mock(): MockFirebaseKMP = MockFirebaseKMPImpl()
}