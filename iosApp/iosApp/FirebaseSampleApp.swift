import SwiftUI
import KotlinLibrary

final class AppDelegate: NSObject {
    let firebaseService = FirebaseService(kmp: FirebaseKMPFactory.shared.firebase())
}

// Firebase must be configured before any other Firebase API is used.
#if os(iOS)
extension AppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        firebaseService.configure()
        return true
    }
}
#elseif os(macOS)
extension AppDelegate: NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        firebaseService.configure()
    }
}
#endif

@main
struct FirebaseSampleApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appDelegate.firebaseService)
        }
    }
}
