import SwiftUI

/// Email/password login and registration.
struct AuthView: View {
    private enum Mode {
        case login, register

        var title: LocalizedStringKey {
            switch self {
            case .login: "Log In"
            case .register: "Create Account"
            }
        }
    }

    @Environment(FirebaseService.self) private var firebase
    @State private var mode = Mode.login

    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .login: LoginForm()
                case .register: RegistrationForm()
                }
            }
            .navigationTitle(mode.title)
            .safeAreaInset(edge: .bottom) {
                Button(mode == .login ? "Don't have an account? Sign up" : "Already have an account? Log in") {
                    mode = mode == .login ? .register : .login
                    firebase.errorMessage = nil
                }
                .padding()
                .disabled(firebase.isLoading)
            }
        }
    }
}

private struct LoginForm: View {
    private enum Field: Hashable { case email, password }

    @Environment(FirebaseService.self) private var firebase
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !firebase.isLoading
    }

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .emailInput()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit(submit)
            } footer: {
                ErrorMessage(text: firebase.errorMessage)
            }

            Section {
                SubmitButton("Log In", isLoading: firebase.isLoading, action: submit)
                    .disabled(!canSubmit)
            }
        }
        .formStyle(.grouped)
    }

    private func submit() {
        guard canSubmit else { return }
        focusedField = nil
        Task { await firebase.signIn(email: email, password: password) }
    }
}

private struct RegistrationForm: View {
    private enum Field: Hashable { case email, displayName, password, confirmPassword }

    @Environment(FirebaseService.self) private var firebase
    @State private var email = ""
    @State private var displayName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    private var passwordsMatch: Bool { password == confirmPassword }

    private var canSubmit: Bool {
        !email.isEmpty && !displayName.isEmpty && !password.isEmpty && passwordsMatch && !firebase.isLoading
    }

    /// Validation is shown inline; Firebase errors (weak password, email in use, ...) come from the service.
    private var errorMessage: String? {
        if !confirmPassword.isEmpty && !passwordsMatch {
            return String(localized: "Passwords don't match.")
        }
        return firebase.errorMessage
    }

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .emailInput()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .displayName }

                TextField("Display Name", text: $displayName)
                    .textContentType(.name)
                    .focused($focusedField, equals: .displayName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }

            Section {
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .confirmPassword }

                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.go)
                    .onSubmit(submit)
            } footer: {
                ErrorMessage(text: errorMessage)
            }

            Section {
                SubmitButton("Create Account", isLoading: firebase.isLoading, action: submit)
                    .disabled(!canSubmit)
            }
        }
        .formStyle(.grouped)
    }

    private func submit() {
        guard canSubmit else { return }
        focusedField = nil
        Task { await firebase.signUp(email: email, password: password, displayName: displayName) }
    }
}

private extension View {
    func emailInput() -> some View {
        #if os(iOS)
        textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        textContentType(.emailAddress)
            .autocorrectionDisabled()
        #endif
    }
}

private struct ErrorMessage: View {
    let text: String?

    var body: some View {
        if let text, !text.isEmpty {
            Text(text)
                .foregroundStyle(.red)
        }
    }
}

private struct SubmitButton: View {
    let title: LocalizedStringKey
    let isLoading: Bool
    let action: () -> Void

    init(_ title: LocalizedStringKey, isLoading: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Keep the label in the layout so the row height doesn't jump while loading.
                Text(title).opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(Text(title))
        .accessibilityValue(isLoading ? Text("In progress") : Text(""))
    }
}

#Preview("Log in") {
    AuthView()
        .environment(FirebaseService.preview())
}
