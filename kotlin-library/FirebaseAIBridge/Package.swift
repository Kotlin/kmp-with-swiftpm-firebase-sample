// swift-tools-version: 6.2
import PackageDescription

// Objective-C compatible wrapper around the pure-Swift FirebaseAILogic SDK.
// SwiftPM import is cinterop-based, so Kotlin only sees @objc declarations;
// this package re-exposes a small FirebaseAILogic API surface with @objc.
let package = Package(
    name: "FirebaseAIBridge",
    platforms: [
        .iOS("18.0"),
        .macOS("15.0"),
    ],
    products: [
        .library(name: "FirebaseAIBridge", targets: ["FirebaseAIBridge"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "13.1.0"),
    ],
    targets: [
        .target(
            name: "FirebaseAIBridge",
            dependencies: [
                .product(name: "FirebaseAILogic", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
