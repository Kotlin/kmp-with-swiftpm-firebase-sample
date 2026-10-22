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

    swiftPMDependencies {
        // Matches IPHONEOS_DEPLOYMENT_TARGET of iosApp.
        iosMinimumDeploymentTarget = "18.0"

        // Only the products used by this module are declared. Transitive Clang modules
        // (FirebaseCore, FirebaseInstallations, ...) are discovered and imported automatically.
        swiftPackage(
            url = url("https://github.com/firebase/firebase-ios-sdk.git"),
            version = from(firebaseVersion),
            products = listOf(
                product("FirebaseAnalytics"),
                product("FirebaseAppCheck"),
                product("FirebaseAppDistribution-Beta"),
                product("FirebaseAuth"),
                product("FirebaseCrashlytics"),
                product("FirebaseDatabase"),
                product("FirebaseFirestore"),
                product("FirebaseFunctions"),
                product("FirebaseInAppMessaging-Beta"),
                product("FirebaseMessaging"),
                product("FirebasePerformance"),
                product("FirebaseRemoteConfig"),
                product("FirebaseStorage"),
            ),
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
