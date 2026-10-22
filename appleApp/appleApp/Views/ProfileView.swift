import SwiftUI

/// Signed-in screen showing the Firestore profile of the current user.
struct ProfileView: View {
    private enum LoadState: Equatable {
        case loading
        case loaded(UserProfile)
        case missing
        case failed(String)
    }

    @Environment(FirebaseService.self) private var firebase
    @State private var state = LoadState.loading

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Sign Out", role: .destructive) {
                            firebase.signOut()
                        }
                    }
                }
        }
        .task(id: firebase.currentUserID) {
            await load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            ProgressView("Loading profile…")
        case .loaded(let profile):
            ProfileDetails(profile: profile)
                .refreshable { await load() }
        case .missing:
            unavailable("No Profile", systemImage: "person.crop.circle.badge.questionmark",
                        description: "No profile is stored for this account yet.")
        case .failed(let message):
            unavailable("Couldn't Load Profile", systemImage: "exclamationmark.triangle", description: message)
        }
    }

    private func unavailable(_ title: LocalizedStringKey, systemImage: String, description: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            Button("Try Again") {
                state = .loading
                Task { await load() }
            }
        }
    }

    private func load() async {
        do {
            state = try await firebase.fetchProfile().map(LoadState.loaded) ?? .missing
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

private struct ProfileDetails: View {
    let profile: UserProfile

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Avatar(url: profile.photoURL)
                    VStack(alignment: .leading) {
                        Text(profile.displayName.isEmpty ? String(localized: "No Name") : profile.displayName)
                            .font(.title2.bold())
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }

            Section("Account Information") {
                LabeledContent("Member since") {
                    if let createdAt = profile.createdAt {
                        Text(createdAt, format: .dateTime.year().month().day())
                    } else {
                        Text("Not available")
                    }
                }
            }
        }
    }
}

private struct Avatar: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else if url != nil && phase.error == nil {
                ProgressView()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.tint)
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(.circle)
        .accessibilityHidden(true)
    }
}

#Preview("Loaded") {
    ProfileView()
        .environment(FirebaseService.preview(user: FirebaseService.previewUser, profile: FirebaseService.previewProfile))
}

#Preview("Missing profile") {
    ProfileView()
        .environment(FirebaseService.preview(user: FirebaseService.previewUser))
}
