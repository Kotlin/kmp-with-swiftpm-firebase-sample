[![official project](http://jb.gg/badges/official.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)
# SwiftUI Firebase KMP Sample

> [!WARNING]
> This CocoaPods version of the sample is no longer maintained. Firebase stops publishing new versions to CocoaPods
> in October 2026, and Firebase 12 is the last major version there
> ([Firebase announcement](https://firebase.google.com/docs/ios/cocoapods-deprecation)).
> The maintained sample uses the Kotlin Gradle Plugin's SwiftPM import instead. It is on the
> [`master` branch](https://github.com/Kotlin/kmp-with-swiftpm-firebase-sample).

A sample iOS app using SwiftUI and a Kotlin Multiplatform (KMP) library for Firebase integration (Auth, Firestore, Analytics).

## Core Idea

* **Shared Logic**: Firebase interactions (auth, data, analytics) in Kotlin.
* **Native UI**: SwiftUI for the iOS frontend.
* **Testable**: Mock Firebase implementations for KMP and SwiftUI Previews.

## Structure

* **`kotlin-library`**: KMP module for Firebase logic and CocoaPods dependencies.
  * **Interfaces**: `FirebaseKMP`, `MockFirebaseKMP`.
  * **Implementations**: `FirebaseKMPImpl` (real), `MockFirebaseKMPImpl` (mock).
  * **Models**: Shared Kotlin data classes (e.g., `FirebaseUser`).
* **`iOSApp`**: SwiftUI application.
  * Consumes `kotlin-library`.
  * `FirebaseService.swift`: `ObservableObject` bridging KMP to SwiftUI (`async/await`, `@Published` state).

## Features

* Email/Password Authentication (Sign-up, Sign-in, Sign-out).
* Firestore for user profile storage and retrieval.
* Firebase Analytics for event logging.
* SwiftUI Previews with a mocked KMP backend.

## Setup & Run

1.  **Prerequisites**: Xcode, Intellij IDEA, CocoaPods.
2.  **Firebase Project**:
  * Create a Firebase project.
  * Register an iOS app and add `GoogleService-Info.plist` to `iOSApp`.
  * Enable Email/Password Auth & configure Firestore rules.
3.  **Build**:
  * `pod install` in the `iosApp` directory.
  * Open `.xcworkspace` in Xcode and run.
