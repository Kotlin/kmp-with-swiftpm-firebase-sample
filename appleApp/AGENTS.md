# appleApp

The SwiftUI app. One multiplatform target and scheme, both named `appleApp`, built for iOS and macOS. The project
uses buildable folders, so new Swift files in `appleApp/appleApp/` are picked up without editing `project.pbxproj`.

## Build settings to keep

- `ENABLE_USER_SCRIPT_SANDBOXING = NO`. The Run Script phase runs Gradle, which reads and writes outside the sandbox.
- `DEAD_CODE_STRIPPING = YES`. FirebaseCore declares constants it never defines, and the macOS link fails on their
  unused cinterop getters without stripping.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. It works here because Swift only calls Kotlin and never subclasses or
  implements Kotlin types.
- `MemberImportVisibility` is on. Import every module whose members a file uses.
- The bundle ID stays `org.jetbrains.kotlin.firebase.sample.iosApp`. It has to match `GoogleService-Info.plist`.

## Swift rules

- iOS-only APIs (UIKit, keyboard modifiers, `iosMain` declarations) go behind `#if os(iOS)`, because the same target
  builds for macOS.
- Views don't touch Kotlin types. `FirebaseService` exposes what they need.
- `FirebaseService` turns the Kotlin callbacks into `async` functions. Kotlin completion blocks are `@Sendable` in Swift.
- The signed-in user comes from `FirebaseKMP.addAuthStateListener`, which also reports sign-outs that Firebase makes on
  its own. Views and auth actions don't write `currentUser` themselves; `performAuthAction` applies the listener's
  value once a sign-in or sign-up flow has finished, so the profile screen doesn't appear before the profile is saved.
- Previews use `FirebaseService.preview(...)`, which is backed by the Kotlin mock. Previews never call Firebase.
