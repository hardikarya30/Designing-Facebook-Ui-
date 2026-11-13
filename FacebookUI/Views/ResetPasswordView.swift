//
//  ResetPasswordView.swift
//  FacebookUI
//
//  Ask for a reset link: email in, confirmation out.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var errorMessage: String?
    @State private var isSent = false

    var body: some View {
        ZStack {
            AppBackground()
            blueGlow

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    backRow

                    content
                        .padding(.top, 10)

                    backToSignIn
                        .padding(.top, 18)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.25), value: isSent)
    }

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

    private var backRow: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Back")

            Spacer()
        }
    }

    @ViewBuilder
    private var content: some View {
        if isSent {
            confirmation
        } else {
            form
        }
    }

    // MARK: - Form

    private var form: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "key.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Theme.cyan.opacity(0.14)))

            Text("Reset your password")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .padding(.top, 16)

            Text("We'll email you a link to choose a new one.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .padding(.top, 6)

            Text("EMAIL ADDRESS")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.tertiaryText)
                .padding(.top, 22)
                .padding(.bottom, 6)

            AuthField(
                icon: "envelope",
                placeholder: "Enter your Email address",
                text: $email,
                contentType: .emailAddress,
                keyboard: .emailAddress
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Theme.rose)
                    .padding(.top, 10)
            }

            Button(action: send) {
                Text("Send reset link")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.midnight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Capsule(style: .continuous).fill(Theme.accent))
                    .shadow(color: Theme.cyan.opacity(0.4), radius: 18, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.top, 20)
        }
    }

    // MARK: - Confirmation

    private var confirmation: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Theme.cyan.opacity(0.14)))

            Text("Check your inbox")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .padding(.top, 16)

            Text("Check your inbox — we sent a link to your address.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)

            Text(email.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.cyan)
                .padding(.top, 8)
        }
    }

    private var backToSignIn: some View {
        HStack(spacing: 5) {
            Text("Remembered it?")
                .foregroundStyle(Theme.secondaryText)

            Button("Back to sign in") {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.cyan)
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
    }

    private func send() {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }

        errorMessage = nil
        isSent = true
    }
}

#Preview {
    ResetPasswordView()
}
