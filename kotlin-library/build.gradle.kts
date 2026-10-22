@file:OptIn(ExperimentalKotlinGradlePluginApi::class)

import org.gradle.kotlin.dsl.withType
import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
}

group = "org.jetbrains.kotlin.firebase.sample"
version = "1.0-SNAPSHOT"

val firebaseVersion = libs.versions.firebase.get()

kotlin {
    iosArm64()
    iosSimulatorArm64()
    macosArm64()

    swiftPMDependencies {
        // Match IPHONEOS_DEPLOYMENT_TARGET and MACOSX_DEPLOYMENT_TARGET of the Xcode app.
        iosMinimumDeploymentTarget = "18.0"
        macosMinimumDeploymentTarget = "15.0"

        // Only the products used by this module are declared. Transitive Clang modules
        // (FirebaseCore, FirebaseInstallations, ...) are discovered and imported automatically.
        // Products that Firebase ships for iOS only are limited to iOS, and their samples live in iosMain.
        swiftPackage(
            url = url("https://github.com/firebase/firebase-ios-sdk.git"),
            version = from(firebaseVersion),
            products = listOf(
                product("FirebaseAnalytics"),
                product("FirebaseAppCheck"),
                product("FirebaseAppDistribution-Beta", platforms = setOf(iOS())),
                product("FirebaseAuth"),
                product("FirebaseCrashlytics"),
                product("FirebaseDatabase"),
                product("FirebaseFirestore"),
                product("FirebaseFunctions"),
                product("FirebaseInAppMessaging-Beta", platforms = setOf(iOS())),
                product("FirebaseMessaging"),
                product("FirebasePerformance", platforms = setOf(iOS())),
                product("FirebaseRemoteConfig"),
                product("FirebaseStorage"),
            ),
        )

        // FirebaseAILogic is a pure-Swift SDK, which cinterop can't import. This local package
        // wraps the needed APIs in @objc classes so they become visible to Kotlin.
        localSwiftPackage(
            directory = layout.projectDirectory.dir("FirebaseAIBridge"),
            products = listOf("FirebaseAIBridge"),
        )
    }

    sourceSets.configureEach {
        languageSettings {
            optIn("kotlinx.cinterop.ExperimentalForeignApi")
        }
    }

    targets
        .withType<KotlinNativeTarget>()
        .matching { it.konanTarget.family.isAppleFamily }
        .configureEach {
            binaries.framework {
                baseName = "KotlinLibrary"
                isStatic = true
            }
        }
}
