import Foundation
import Observation
import KotlinLibrary

typealias KMPFirebaseUser = KotlinLibrary.FirebaseUser

/// Profile stored in the Firestore `users/{uid}` document.
struct UserProfile: Equatable {
    var displayName: String
    var email: String
    var photoURL: URL?
    var createdAt: Date?
}

extension UserProfile {
    init(document: [String: Any]) {
        displayName = document["displayName"] as? String ?? ""
        email = document["email"] as? String ?? ""
        photoURL = (document["photoURL"] as? String).flatMap(URL.init(string:))
        createdAt = (document["createdAt"] as? TimeInterval).map(Date.init(timeIntervalSince1970:))
    }

    var document: [String: Any] {
        var document: [String: Any] = ["displayName": displayName, "email": email]
        if let photoURL { document["photoURL"] = photoURL.absoluteString }
        if let createdAt { document["createdAt"] = createdAt.timeIntervalSince1970 }
        return document
    }
}

enum FirebaseServiceError: LocalizedError {
    case missingUser

    var errorDescription: String? {
        switch self {
        case .missingUser: "The account was created, but no user was returned."
        }
    }
}

/// Bridges the callback-based `FirebaseKMP` API of the Kotlin library to SwiftUI.
///
/// Views observe `currentUser`, `isLoading` and `errorMessage`; every Firebase call goes through
/// the injected `FirebaseKMP`, so previews can swap in the Kotlin mock.
@Observable
final class FirebaseService {
    private(set) var currentUser: KMPFirebaseUser?
    private(set) var isLoading = false
    var errorMessage: String?

    var isSignedIn: Bool { currentUser != nil }
    var currentUserID: String? { currentUser?.uid }

    private let kmp: FirebaseKMP

    /// A profile from sign-up that couldn't be written yet. `fetchProfile()` retries the write.
    @ObservationIgnored private var unsavedProfile: UserProfile?

    init(kmp: FirebaseKMP) {
        self.kmp = kmp
    }

    func configure() {
        kmp.configure()
        refreshAuthState()
    }

    // MARK: - Authentication

    func signIn(email: String, password: String) async {
        await performAuthAction(failureEvent: "login_failure") {
            _ = try await bridge { kmp.signIn(email: email, password: password, completion: $0) }
            kmp.logEvent(name: "login", parameters: ["method": "email"])
        }
    }

    func signUp(email: String, password: String, displayName: String) async {
        await performAuthAction(failureEvent: "sign_up_failure") {
            let user = try await bridge { kmp.signUp(email: email, password: password, completion: $0) }
            guard let userId = (user ?? kmp.getCurrentUser())?.uid else {
                throw FirebaseServiceError.missingUser
            }

            // The account exists at this point, so a failed profile write doesn't fail the sign-up.
            // The profile screen shows the error and retries the write when it loads the profile.
            let profile = UserProfile(displayName: displayName, email: email, createdAt: .now)
            do {
                try await save(profile, userId: userId)
            } catch {
                unsavedProfile = profile
                kmp.logEvent(name: "profile_save_failure", parameters: ["error": error.localizedDescription])
            }

            kmp.setUserId(userId: userId)
            kmp.setUserProperty(name: "user_type", value: "new_user")
            kmp.logEvent(name: "sign_up", parameters: ["method": "email"])
        }
    }

    func signOut() {
        kmp.logEvent(name: "sign_out", parameters: nil)
        errorMessage = kmp.signOut() ? nil : "Couldn't sign out. Please try again."
        unsavedProfile = nil
        refreshAuthState()
    }

    // MARK: - Firestore

    /// Loads the signed-in user's profile, or returns `nil` when no profile document exists.
    /// A profile that sign-up couldn't write is written first.
    func fetchProfile() async throws -> UserProfile? {
        guard let userId = currentUser?.uid else { return nil }
        if let unsavedProfile {
            try await save(unsavedProfile, userId: userId)
            self.unsavedProfile = nil
        }
        let document = try await bridge { kmp.getUser(userId: userId, completion: $0) }
        return document.map(UserProfile.init(document:))
    }

    private func save(_ profile: UserProfile, userId: String) async throws {
        try await bridge { kmp.saveUser(userId: userId, userData: profile.document, completion: $0) }
    }

    // MARK: - Helpers

    /// Runs an auth flow with shared loading/error handling.
    ///
    /// The published auth state is refreshed only once the whole flow finishes, so the UI doesn't
    /// switch to the profile screen while sign-up is still writing the profile document.
    private func performAuthAction(failureEvent: String, _ action: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            refreshAuthState()
        }

        do {
            try await action()
        } catch {
            errorMessage = error.localizedDescription
            kmp.logEvent(name: failureEvent, parameters: ["error": error.localizedDescription])
        }
    }

    private func refreshAuthState() {
        currentUser = kmp.isUserSignedIn() ? kmp.getCurrentUser() : nil
    }

    private func bridge<Value>(
        _ start: (@escaping @Sendable (Value?, KMPError?) -> Void) -> Void
    ) async throws -> Value? {
        try await withCheckedThrowingContinuation { continuation in
            start { value, error in
                if let error {
                    continuation.resume(throwing: error.nsError)
                } else {
                    continuation.resume(returning: value)
                }
            }
        }
    }

    private func bridge(_ start: (@escaping @Sendable (KMPError?) -> Void) -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            start { error in
                if let error {
                    continuation.resume(throwing: error.nsError)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
extension FirebaseService {
    static let previewUser = KMPFirebaseUser(
        uid: "preview-user",
        email: "kate.bell@example.com",
        displayName: "Kate Bell",
        photoURL: nil
    )

    static let previewProfile = UserProfile(
        displayName: "Kate Bell",
        email: "kate.bell@example.com",
        createdAt: .now.addingTimeInterval(-30 * 86_400)
    )

    /// A service backed by the Kotlin `MockFirebaseKMP`, optionally signed in with a stored profile.
    static func preview(user: KMPFirebaseUser? = nil, profile: UserProfile? = nil) -> FirebaseService {
        let mock = FirebaseKMPFactory.shared.mock()
        mock.signedInUserOverride = user
        if let user, let profile {
            mock.saveUser(userId: user.uid, userData: profile.document) { _ in }
        }
        let service = FirebaseService(kmp: mock)
        service.configure()
        return service
    }
}
#endif
