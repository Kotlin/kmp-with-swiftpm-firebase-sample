# Agent guidelines

This repository is a sample of a Kotlin Multiplatform library that uses the Firebase Apple SDK through the Kotlin Gradle
Plugin's SwiftPM import, and a SwiftUI app for iOS and macOS that uses the library. People read it to learn SwiftPM
import, so the code has to be correct, small and easy to follow. `README.md` explains the structure and the setup.

## Layout

- `kotlin-library/` - The KMP module, built as the static `KotlinLibrary` framework. Rules for it are in
  `kotlin-library/AGENTS.md`.
- `appleApp/` - The SwiftUI app, one target for iOS and macOS. Rules for it are in `appleApp/AGENTS.md`.
- Generated and committed: `appleApp/KotlinMultiplatformLinkedPackage/` (read-only, never edit it by hand) and
  `.swiftpm-locks/default/swiftImport/Package.resolved`. Commit both whenever a build changes them.

## Build and verify

There are no tests yet, so build what your change touches. A change to the Kotlin API touches everything.

- Kotlin: `./gradlew :kotlin-library:compileKotlinIosSimulatorArm64 :kotlin-library:compileKotlinIosArm64 :kotlin-library:compileKotlinMacosArm64`
- iOS app: `xcodebuild build -project appleApp/appleApp.xcodeproj -scheme appleApp -sdk iphonesimulator -arch arm64 -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO`
- macOS app: `xcodebuild build -project appleApp/appleApp.xcodeproj -scheme appleApp -destination 'platform=macOS,arch=arm64' -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO`

Don't run Gradle from the command line while the IDE is syncing the project. Both run `xcodebuild` in the same
`build/kotlin/swiftPMXcodeDumps` directory and fail with "database is locked".

## Dependencies

- The Firebase version is set in `gradle/libs.versions.toml` and `kotlin-library/FirebaseAIBridge/Package.swift`.
- The deployment targets (iOS 18, macOS 15) are set in `kotlin-library/build.gradle.kts`,
  `kotlin-library/FirebaseAIBridge/Package.swift` and the Xcode project.
- Change all copies of a version together.

## Code style

- Comments and docs are short and plain. Say what the code does and why.
- Keep `README.md` in sync with the code. Every claim in it should be something the sample shows.

## Commits

Small, focused commits with a short imperative subject, for example "Add a Cloud Functions sample". No
`Co-Authored-By` trailers.
