package org.jetbrains.kotlin.firebase.sample

import swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library.FIRUser
import platform.Foundation.NSError

internal fun FIRUser.toKMPUser(): FirebaseUser {
    return FirebaseUser(
        uid = this.uid(),
        email = this.email() ?: "",
        displayName = this.displayName(),
        photoURL = this.photoURL()?.absoluteString
    )
}

internal fun NSError.toKMPError(): KMPError {
    return KMPError(this)
}

/**
 * Passes an Objective-C completion result to a Kotlin callback: the value on success, the error otherwise.
 */
internal fun <T> ((T?, KMPError?) -> Unit).complete(value: T?, error: NSError?) {
    if (error != null) this(null, error.toKMPError()) else this(value, null)
}
