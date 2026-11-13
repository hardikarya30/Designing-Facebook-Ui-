//
//  EmailVerificationView.swift
//  FacebookUI
//
//  Verify your email address by sending a link to it.
//

import SwiftUI

struct EmailVerificationView: View {
    let email: String

    @Environment(\.dismiss) private var dismiss

    @State private var emailField: String
    @State private var errorMessage: String?
    @State private var isSent = false

    init(email: String) {
        self.email = email
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        _emailField = State(initialValue: trimmed.isEmpty ? "hardikarya30@gmail.com" : trimmed)
    }

    private var displayEmail: String {
        var value = emailField.trimmingCharacters(in: .whitespacesAndNewlines)
        let suffix = "gmail.com"

        if !value.contains("@"), value.lowercased().hasSuffix(suffix) {
            value = String(value.dropLast(suffix.count)) + "@" + suffix
        }

        return value.isEmpty ? "your email address" : value
    }

    var body: some View {
        ZStack {
            AppBackground()
            blueGlow

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    backRow

                    if isSent {
                        sentContent
                    } else {
                        formContent
                    }
                }
                .padding(20)
            }
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

    // MARK: - Before sending

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Theme.cyan.opacity(0.14)))
                .padding(.top, 10)

            Text("Verify your email address")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .padding(.top, 16)
                .fixedSize(horizontal: false, vertical: true)

            Text("We'll send a verification link to")
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
                text: $emailField,
                contentType: .emailAddress,
                keyboard: .emailAddress
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Theme.rose)
                    .padding(.top, 10)
            }

            Button {
                sendLink()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 14, weight: .bold))

                    Text("Send verification link")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Capsule(style: .continuous).fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.4), radius: 18, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.top, 24)
        }
    }

    // MARK: - After sending

    private var sentContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Theme.cyan.opacity(0.14)))
                .padding(.top, 10)

            Text("Link sent")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .padding(.top, 16)

            Text("Check \(displayEmail) for the verification link.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)

            Text(displayEmail)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.cyan)
                .padding(.top, 4)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                isSent = false
            } label: {
                Text("Send again")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule(style: .continuous).fill(Color.white.opacity(0.07)))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 22)
        }
    }

    private func sendLink() {
        guard !emailField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }

        errorMessage = nil
        isSent = true
    }
}

#Preview {
    EmailVerificationView(email: "hardikarya30@gmail.com")
}
