import SwiftUI

/// Root view: shows the profile when signed in, otherwise the login/registration flow.
struct ContentView: View {
    @Environment(FirebaseService.self) private var firebase

    var body: some View {
        Group {
            if firebase.isSignedIn {
                ProfileView()
            } else {
                AuthView()
            }
        }
        .animation(.default, value: firebase.isSignedIn)
    }
}

#Preview("Signed out") {
    ContentView()
        .environment(FirebaseService.preview())
}

#Preview("Signed in") {
    ContentView()
        .environment(FirebaseService.preview(user: FirebaseService.previewUser, profile: FirebaseService.previewProfile))
}
