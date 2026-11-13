//
//  AccountSettingsView.swift
//  FacebookUI
//
//  Account settings: details, notifications, privacy, support and sign out.
//

import SwiftUI

struct AccountSettingsView: View {
    var name: String
    var email: String
    var phone: String
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var storiesStore: StoriesStore
    var onSignOut: () -> Void
    var onChangePassword: (String, String) -> Bool = { _, _ in false }

    @AppStorage("settings.pushNotifications") private var pushNotifications = true
    @AppStorage("settings.emailNotifications") private var emailNotifications = true
    @AppStorage("settings.privateAccount") private var privateAccount = false

    @Environment(\.dismiss) private var dismiss
    @State private var isSignOutConfirmPresented = false
    @State private var isLoginSecurityPresented = false
    @State private var isAdPreferencesPresented = false
    @State private var isMetaPayPresented = false
    @State private var isMediaGalleryPresented = false

    private var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not set" : trimmed
    }

    private var displayEmail: String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not set" : trimmed
    }

    private var displayPhone: String {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Not set" : trimmed
    }

    private var mediaCountDetail: String? {
        let postPhotos = feedStore.publishedPosts.filter { $0.imageName != nil }.count
        let storyPhotos = storiesStore.myStories.filter { $0.imageName != nil }.count
        let total = postPhotos + storyPhotos + SampleProfile.photos.count

        guard total > 0 else { return nil }
        return total == 1 ? "1 photo" : "\(total) photos"
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    section("LOGIN AND SECURITY") {
                        Button {
                            isLoginSecurityPresented = true
                        } label: {
                            navigationRow(title: "Login and security", detail: "3 recommended actions")
                        }
                        .buttonStyle(.plain)
                    }

                    section("CROSS-PROFILE EXPERIENCES") {
                        navigationRow(title: "Cross-profile experiences")
                    }

                    section("YOUR INFORMATION AND PERMISSIONS") {
                        Button {
                            isAdPreferencesPresented = true
                        } label: {
                            navigationRow(title: "Ad preferences")
                        }
                        .buttonStyle(.plain)
                        divider
                        Button {
                            isMetaPayPresented = true
                        } label: {
                            navigationRow(title: "Meta Pay")
                        }
                        .buttonStyle(.plain)
                        divider
                        navigationRow(title: "Subscriptions", detail: "$")
                        divider
                        Button {
                            isMediaGalleryPresented = true
                        } label: {
                            navigationRow(title: "Your media gallery", detail: mediaCountDetail)
                        }
                        .buttonStyle(.plain)
                    }

                    section("ACCOUNT") {
                        infoRow(icon: "person.fill", title: "Name", value: displayName)
                        divider
                        infoRow(icon: "envelope.fill", title: "Email", value: displayEmail)
                        divider
                        infoRow(icon: "phone.fill", title: "Phone", value: displayPhone)
                    }

                    section("NOTIFICATIONS") {
                        toggleRow("Push notifications", value: $pushNotifications)
                        divider
                        toggleRow("Email notifications", value: $emailNotifications)
                    }

                    section("PRIVACY") {
                        toggleRow(
                            "Private account",
                            subtitle: "Only friends can see your posts",
                            value: $privateAccount
                        )
                    }

                    section("SUPPORT") {
                        infoRow(icon: "questionmark.circle.fill", title: "Help centre", value: "Guides and answers")
                        divider
                        infoRow(icon: "info.circle.fill", title: "About", value: "social. 1.0")
                    }

                    signOutRow
                        .padding(.top, 4)

                    Color.clear
                        .frame(height: 8)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isMetaPayPresented) {
            MetaPayView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isLoginSecurityPresented) {
            LoginSecurityView(onChangePassword: onChangePassword)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isAdPreferencesPresented) {
            AdPreferencesView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isMediaGalleryPresented) {
            MediaGalleryView(feedStore: feedStore, storiesStore: storiesStore)
        }
        .confirmationDialog(
            "Sign out of your account?",
            isPresented: $isSignOutConfirmPresented,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {
                dismiss()
                onSignOut()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your posts and profile stay saved on this device.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                GlassIconButton(systemName: "chevron.left", size: 40) {
                    dismiss()
                }
                .accessibilityLabel("Back")

                Spacer()
            }

            Text("Settings")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Theme.primaryText)
        }
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Theme.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .glassSurface(cornerRadius: Theme.Radius.card)
        }
    }

    private func navigationRow(title: String, detail: String? = nil) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1)

            Spacer(minLength: 8)

            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
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
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func toggleRow(
        _ title: String,
        subtitle: String? = nil,
        value: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer(minLength: 8)

            Toggle(title, isOn: value)
                .labelsHidden()
                .tint(Theme.cyan)
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

    private var signOutRow: some View {
        Button {
            isSignOutConfirmPresented = true
        } label: {
            Text("Sign out")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.rose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glassSurface(cornerRadius: Theme.Radius.card)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AccountSettingsView(
        name: "Alex Morgan",
        email: "alex@example.com",
        phone: "+44 7700 900123",
        feedStore: FeedStore(),
        storiesStore: StoriesStore(),
        onSignOut: {}
    )
}
