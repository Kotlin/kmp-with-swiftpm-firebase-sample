import SwiftUI
import KotlinLibrary

final class AppDelegate: NSObject, UIApplicationDelegate {
    let firebaseService = FirebaseService(kmp: FirebaseKMPFactory.shared.firebase())

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase must be configured before any other Firebase API is used.
        firebaseService.configure()
        return true
    }
}

@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appDelegate.firebaseService)
        }
    }
}
