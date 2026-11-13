//
//  AuthView.swift
//  FacebookUI
//
//  Sign in and sign up, on the app's blue glass.
//

import SwiftUI

enum AuthMode {
    case signIn
    case signUp
}

struct AuthView: View {
    @ObservedObject var auth: AuthStore

    @State private var mode: AuthMode = .signIn

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isResetPresented = false
    @State private var isVerifyPresented = false

    var body: some View {
        ZStack {
            AppBackground()
            blueGlow

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    wordmark

                    Text(mode == .signIn ? "Welcome back" : "Create your account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                        .padding(.top, 26)

                    Text(mode == .signIn
                         ? "Sign in to pick up where you left off."
                         : "Join to share posts, stories and messages.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 6)

                    card
                        .padding(.top, 20)

                    staySignedInRow
                        .padding(.top, 12)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Theme.rose)
                            .padding(.top, 10)
                    }

                    primaryButton
                        .padding(.top, 20)

                    if mode == .signIn {
                        Button("Forgot password?") {
                            isResetPresented = true
                        }
                        .buttonStyle(.plain)
                        .font(.footnote)
                        .foregroundStyle(Theme.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                    }

                    switchButton
                        .padding(.top, 18)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.25), value: mode)
        .fullScreenCover(isPresented: $isResetPresented) {
            ResetPasswordView()
        }
        .fullScreenCover(isPresented: $isVerifyPresented) {
            VerifyPhoneView(auth: auth)
        }
    }

    // MARK: - Background

    private var blueGlow: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: "1D5AC4").opacity(0.55), Color(hex: "1D5AC4").opacity(0)],
                center: UnitPoint(x: 0.5, y: 0.08),
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [Theme.cyan.opacity(0.22), Theme.cyan.opacity(0)],
                center: UnitPoint(x: 0.15, y: 0.85),
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var wordmark: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("social.")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(Theme.accent)

            Text("CONNECT YOUR WORLD")
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundStyle(Theme.secondaryText)
        }
    }

    // MARK: - Form

    private var card: some View {
        VStack(spacing: 12) {
            if mode == .signUp {
                AuthField(
                    icon: "person",
                    placeholder: "Enter your full name",
                    text: $fullName,
                    contentType: .name
                )
            }

            AuthField(
                icon: "envelope",
                placeholder: mode == .signIn ? "Enter your Email address" : "Enter your Email addresses",
                text: $email,
                contentType: .emailAddress,
                keyboard: .emailAddress
            )

            if mode == .signUp {
                AuthField(
                    icon: "phone",
                    placeholder: "Enter your Phone number",
                    text: $phone,
                    contentType: .telephoneNumber,
                    keyboard: .phonePad
                )
            }

            AuthField(
                icon: "lock",
                placeholder: "Enter Password",
                text: $password,
                contentType: .password,
                isSecure: true
            )
        }
        .padding(16)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.55)
    }

    private var staySignedInRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text("Stay signed in")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text("You won't be asked to sign in each time you open the app.")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 6)

            Toggle("", isOn: Binding(
                get: { auth.staySignedIn },
                set: { auth.setStaySignedIn($0) }
            ))
            .labelsHidden()
            .tint(Theme.cyan)
        }
        .padding(14)
        .glassSurface(cornerRadius: Theme.Radius.field, tintOpacity: 0.5, shadowed: false)
    }

    private var primaryButton: some View {
        Button {
            submit()
        } label: {
            Text(mode == .signIn ? "Sign in" : "Sign up")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Capsule(style: .continuous).fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.4), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var switchButton: some View {
        HStack(spacing: 5) {
            Text(mode == .signIn ? "New here?" : "Already have an account?")
                .foregroundStyle(Theme.secondaryText)

            Button(mode == .signIn ? "Create an account" : "Sign in") {
                errorMessage = nil
                mode = mode == .signIn ? .signUp : .signIn
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.cyan)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
    }

    private func submit() {
        if mode == .signIn {
            if auth.signIn(email: email, password: password) {
                errorMessage = nil
            } else if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || password.isEmpty {
                errorMessage = "Please fill in every field."
            } else {
                errorMessage = "Wrong email or password. Try again."
            }
        } else {
            if auth.signUp(fullName: fullName, email: email, password: password, phone: phone) {
                errorMessage = nil
                isVerifyPresented = true
            } else {
                errorMessage = "Please fill in every field."
            }
        }
    }
}

// MARK: - Field

struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.subheadline)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.cyan)
            .textContentType(contentType)
            .keyboardType(keyboard)
            .autocorrectionDisabled()
            .textInputAutocapitalization(isSecure || keyboard == .emailAddress ? .never : .words)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .glassSurface(cornerRadius: Theme.Radius.field, shadowed: false)
    }
}

#Preview {
    AuthView(auth: AuthStore())
}
