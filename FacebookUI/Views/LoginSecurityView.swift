//
//  LoginSecurityView.swift
//  FacebookUI
//
//  Account password, two-step verification and logged-in devices.
//

import SwiftUI

private struct SecurityDevice: Identifiable {
    let id: String
    let name: String
    let activity: String

    static let examples = [
        SecurityDevice(id: "iphone", name: "iPhone 15", activity: "London, 2h ago"),
        SecurityDevice(id: "macbook", name: "MacBook Air", activity: "London, 3d ago")
    ]
}

struct LoginSecurityView: View {
    let onChangePassword: (String, String) -> Bool

    @Environment(\.dismiss) private var dismiss
    @AppStorage("auth.twoStep") private var isTwoStepEnabled = false
    @State private var devices = SecurityDevice.examples
    @State private var isChangePasswordPresented = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    recommendedActions
                    passwordCard
                    twoStepCard
                    devicesCard
                    changePasswordButton
                        .padding(.top, 2)

                    Color.clear.frame(height: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.35, dampingFraction: 0.84), value: isTwoStepEnabled)
        .sheet(isPresented: $isChangePasswordPresented) {
            ChangePasswordSheet(onSave: onChangePassword)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Back")

            Spacer()
        }
        .overlay {
            Text("Login and security")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsHitTesting(false)
        }
        .padding(.bottom, 18)
    }

    private var recommendedActions: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))
                .shadow(color: Theme.cyan.opacity(0.5), radius: 14)

            Text("3 recommended actions")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.cyan)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "9DB7E5"))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .glassSurface(cornerRadius: Theme.Radius.bar, tintOpacity: 0.62)
    }

    private var passwordCard: some View {
        Button {
            isChangePasswordPresented = true
        } label: {
            HStack(spacing: 15) {
                SecurityIconBadge(systemName: "key.fill", tint: Theme.cyan)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Last changed 3 months ago")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "AFC3E3"))
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "9DB7E5"))
            }
            .padding(14)
            .contentShape(Rectangle())
            .glassSurface(cornerRadius: 22, tintOpacity: 0.62)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Password, last changed 3 months ago")
    }

    private var twoStepCard: some View {
        HStack(spacing: 15) {
            SecurityIconBadge(systemName: "lock.fill", tint: Theme.violet)

            VStack(alignment: .leading, spacing: 5) {
                Text("Two-step verification")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Text("We'll ask for a code on new devices")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "AFC3E3"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Toggle("Two-step verification", isOn: $isTwoStepEnabled)
                .labelsHidden()
                .tint(Theme.cyan)
                .accessibilityLabel("Two-step verification")
        }
        .padding(14)
        .glassSurface(cornerRadius: 22, tintOpacity: 0.62)
    }

    private var devicesCard: some View {
        HStack(alignment: .top, spacing: 15) {
            SecurityIconBadge(systemName: "iphone.and.arrow.forward", tint: Color(hex: "489BFF"))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 13) {
                Text("Your devices")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .padding(.top, 3)

                ForEach(devices) { device in
                    HStack(spacing: 8) {
                        Text("\(device.name) · \(device.activity)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: "AFC3E3"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer(minLength: 0)

                        Button("Sign out") {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                devices.removeAll { $0.id == device.id }
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "50BFFF"))
                        .buttonStyle(.plain)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 22, tintOpacity: 0.62)
        .accessibilityElement(children: .contain)
    }

    private var changePasswordButton: some View {
        Button {
            isChangePasswordPresented = true
        } label: {
            Text("Change password")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: "081327"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Capsule(style: .continuous).fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.32), radius: 18, y: 7)
        }
        .buttonStyle(.plain)
    }
}

private struct SecurityIconBadge: View {
    let systemName: String
    let tint: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 24, weight: .medium))
            .foregroundStyle(tint)
            .frame(width: 58, height: 58)
            .background(Circle().fill(tint.opacity(0.08)))
            .overlay {
                Circle()
                    .strokeBorder(tint.opacity(0.9), lineWidth: 1.8)
            }
            .shadow(color: tint.opacity(0.22), radius: 9)
    }
}

private struct ChangePasswordSheet: View {
    let onSave: (String, String) -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Change password")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(Theme.primaryText)

                        Spacer()

                        GlassIconButton(systemName: "xmark", size: 36) {
                            dismiss()
                        }
                        .accessibilityLabel("Close")
                    }
                    .padding(.bottom, 3)

                    PasswordEntryField(title: "Current password", text: $currentPassword, contentType: .password)
                    PasswordEntryField(title: "New password", text: $newPassword, contentType: .newPassword)
                    PasswordEntryField(title: "Confirm new password", text: $confirmPassword, contentType: .newPassword)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Theme.rose)
                    }

                    Button(action: save) {
                        Text("Save")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.midnight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule(style: .continuous).fill(Theme.accent))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in every field."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "New passwords don't match."
            return
        }

        guard onSave(currentPassword, newPassword) else {
            errorMessage = "Current password is incorrect."
            return
        }

        dismiss()
    }
}

private struct PasswordEntryField: View {
    let title: String
    @Binding var text: String
    let contentType: UITextContentType

    var body: some View {
        SecureField(title, text: $text)
            .font(.subheadline)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.cyan)
            .textContentType(contentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .glassSurface(cornerRadius: Theme.Radius.field, shadowed: false)
    }
}

#Preview {
    LoginSecurityView(onChangePassword: { _, _ in true })
}
