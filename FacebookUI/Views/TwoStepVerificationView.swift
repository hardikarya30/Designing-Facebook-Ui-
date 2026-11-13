//
//  TwoStepVerificationView.swift
//  FacebookUI
//
//  Extra security for the account: a switch and the confirmed ways to
//  receive the second code.
//

import SwiftUI

struct TwoStepVerificationView: View {
    var email: String
    var phone: String

    @AppStorage("auth.twoStep") private var isEnabled = false
    @State private var isShowingOffConfirm = false

    @Environment(\.dismiss) private var dismiss

    private var displayEmail: String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "No email added" : trimmed
    }

    private var displayPhone: String {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "No phone added" : trimmed
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    backRow

                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.violet)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Theme.violet.opacity(0.18)))
                        .padding(.top, 10)

                    Text("Extra security for your account")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                        .padding(.top, 16)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("We'll ask for a second code when you sign in on a new device.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 6)
                        .fixedSize(horizontal: false, vertical: true)

                    switchRow
                        .padding(.top, 22)

                    if isEnabled {
                        contactRows
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: 0)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isEnabled)
        .confirmationDialog(
            "Turn off two-step verification?",
            isPresented: $isShowingOffConfirm,
            titleVisibility: .visible
        ) {
            Button("Turn off", role: .destructive) {
                isEnabled = false
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your account will be less protected on new devices.")
        }
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

    private var switchRow: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Two-step verification")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text("Recommended")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            Toggle("Two-step verification", isOn: Binding(
                get: { isEnabled },
                set: { newValue in
                    if newValue {
                        isEnabled = true
                    } else {
                        isShowingOffConfirm = true
                    }
                }
            ))
            .labelsHidden()
            .tint(Theme.cyan)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .glassSurface(cornerRadius: 22)
    }

    private var contactRows: some View {
        VStack(spacing: 0) {
            contactRow(icon: "envelope.fill", title: "Email", value: displayEmail)
            divider
            contactRow(icon: "phone.fill", title: "Phone", value: displayPhone)
        }
        .glassSurface(cornerRadius: 22)
    }

    private func contactRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(value)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Theme.cyan.opacity(0.14)))
                .accessibilityLabel("Confirmed")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
            .padding(.leading, 56)
    }
}

#Preview {
    TwoStepVerificationView(email: "alex@example.com", phone: "+44 7700 900123")
}
