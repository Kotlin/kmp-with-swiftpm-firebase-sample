# kotlin-library

The KMP module, built as the static `KotlinLibrary` framework for `iosArm64`, `iosSimulatorArm64` and `macosArm64`.

- `src/commonMain/` - The `FirebaseKMP` API that Swift calls, and its mock.
- `src/appleMain/` - The Firebase implementation, one service class per product, and one sample per product.
- `src/iosMain/` - Samples for products that Firebase ships for iOS only.
- `FirebaseAIBridge/` - A local Swift package that wraps the Swift-only `FirebaseAILogic` SDK in `@objc` classes so
  Kotlin can call it.

## Using an imported Firebase API

Imported Objective-C APIs live in the Kotlin package `swiftPMImport.org.jetbrains.kotlin.firebase.sample.kotlin.library`.
Before you write Kotlin against one, check its imported signature. Selector names, nullability and Kotlin parameter
names are easy to guess wrong:

```shell
~/.konan/kotlin-native-prebuilt-macos-aarch64-<kotlin version>/bin/klib dump-metadata \
  kotlin-library/build/classes/kotlin/iosSimulatorArm64/main/cinterop/kotlin-library-cinterop-swiftPMImport
```

## SwiftPM import rules

- Declare only the products that Kotlin code uses directly. The plugin imports the Clang modules of transitive
  dependencies (`FirebaseCore`, `FirebaseInstallations`, ...) on its own.
- Kotlin only sees Objective-C compatible APIs. Swift products with `@objc` APIs, such as `FirebaseFunctions`, work
  directly. For a Swift-only product, add `@objc` wrappers to `FirebaseAIBridge` or another local package and declare
  it with `localSwiftPackage(...)`.
- Limit a product that Firebase ships only for iOS with `product("...", platforms = setOf(iOS()))` and put its code in
  `src/iosMain/`. App Distribution, In-App Messaging and Performance are iOS-only.
- Don't add `kotlin.mpp.enableCInteropCommonization`. The plugin turns it on when SwiftPM dependencies exist.
- The CocoaPods plugin can't be combined with `swiftPMDependencies {}`.

## After changing `swiftPMDependencies {}`

The first Xcode build regenerates `appleApp/KotlinMultiplatformLinkedPackage` and fails with "Synthetic linkage
package files changed during the build" and "Please go to File -> Package -> Resolve Package Versions in Xcode". Build
again, then commit the regenerated files and `.swiftpm-locks/default/swiftImport/Package.resolved`.
