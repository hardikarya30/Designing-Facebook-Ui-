//
//  ProfileView.swift
//  FacebookUI
//
//  The signed-in user's profile: cover, identity, stats, Edit profile,
//  and the Posts, Photos and About tabs.
//

import Foundation
import SwiftUI

enum ProfileTab: String, CaseIterable, Identifiable {
    case posts = "Posts"
    case photos = "Photos"
    case about = "About"

    var id: String { rawValue }
    var title: String { rawValue }
}

private enum ProfileSheet: String, Identifiable {
    case edit
    case following
    case saved
    case verifyEmail
    case twoStep
    case discovery
    case settings

    var id: String { rawValue }
}

struct ProfileView: View {
    @ObservedObject var profileStore: ProfileStore
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var savedStore: SavedPostsStore
    @ObservedObject var storiesStore: StoriesStore
    @ObservedObject var pinnedStore: PinnedPostStore
    var onOpenFriends: () -> Void = {}
    var onOpenPost: (Post) -> Void = { _ in }
    var onSignOut: () -> Void = {}
    var onChangePassword: (String, String) -> Bool = { _, _ in false }
    var accountEmail: String = ""
    var accountPhone: String = ""
    var accountName: String = ""

    @State private var tab: ProfileTab = .posts
    @State private var sheet: ProfileSheet?
    @State private var selectedPhoto: ProfilePhoto?
    @State private var selectedStory: Story?
    @State private var isComposerPresented = false
    @State private var isSignOutConfirmPresented = false
    @State private var isAddressPresented = false
    @StateObject private var addressStore = AddressStore()

    private var profile: Profile { profileStore.profile }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    coverHeader

                    VStack(alignment: .leading, spacing: 16) {
                        identity
                        highlights
                        stats
                        buttons
                        ProfileSegmentedControl(selection: $tab)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    tabContent
                        .padding(.top, 16)

                    Color.clear
                        .frame(height: 104)
                }
            }
        }
        .sheet(item: $sheet) { presented in
            switch presented {
            case .edit:
                EditProfileView(store: profileStore)
            case .following:
                FollowingSheet(people: SampleProfile.following)
            case .saved:
                SavedPostsView(savedStore: savedStore, feedStore: feedStore)
            case .verifyEmail:
                EmailVerificationView(email: accountEmail)
            case .twoStep:
                TwoStepVerificationView(email: accountEmail, phone: accountPhone)
            case .discovery:
                DiscoveryTopicsView()
            case .settings:
                AccountSettingsView(
                    name: accountName,
                    email: accountEmail,
                    phone: accountPhone,
                    feedStore: feedStore,
                    storiesStore: storiesStore,
                    onSignOut: onSignOut,
                    onChangePassword: onChangePassword
                )
            }
        }
        .fullScreenCover(item: $selectedPhoto) { photo in
            ProfilePhotoView(photo: photo)
        }
        .fullScreenCover(item: $selectedStory) { story in
            StoryViewer(stories: storiesStore.viewerStories, startID: story.id)
        }
        .fullScreenCover(isPresented: $isComposerPresented) {
            StoryComposerView(store: storiesStore)
        }
        .fullScreenCover(isPresented: $isAddressPresented, onDismiss: { addressStore.refresh() }) {
            MyAddressView(onBack: { isAddressPresented = false })
        }
        .confirmationDialog(
            "Sign out of your account?",
            isPresented: $isSignOutConfirmPresented,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {
                onSignOut()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your posts and profile stay saved on this device.")
        }
    }

    // MARK: - Cover

    private var coverHeader: some View {
        CoverCard {
            ProfilePictureView(size: 104)
                .offset(y: 48)
        }
        .padding(.bottom, 56)
    }

    // MARK: - Identity

    private var identity: some View {
        VStack(spacing: 5) {
            Text(profile.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(identityLine)
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)

            if !profile.bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundStyle(Theme.primaryText.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var identityLine: String {
        let parts = [profile.handle, profile.role]
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return parts.joined(separator: " · ")
    }

    // MARK: - Story highlights

    @ViewBuilder
    private var highlights: some View {
        if storiesStore.hasStory {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(storiesStore.myStories.prefix(5)) { story in
                        Button {
                            selectedStory = story
                        } label: {
                            highlight(story)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(story.caption.isEmpty ? "Your story" : story.caption)
                    }

                    Button {
                        isComposerPresented = true
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.cyan)
                                .frame(width: 64, height: 64)
                                .background(Circle().fill(Color.white.opacity(0.05)))
                                .overlay {
                                    Circle()
                                        .strokeBorder(
                                            Theme.cyan.opacity(0.35),
                                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                                        )
                                }

                            Text("New")
                                .font(.caption2)
                                .foregroundStyle(Theme.secondaryText)
                                .frame(width: 66)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add another highlight")
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func highlight(_ story: Story) -> some View {
        VStack(spacing: 6) {
            ZStack {
                if let imageName = story.imageName {
                    Color.clear
                        .overlay {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                } else {
                    LinearGradient(
                        colors: story.media.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: story.symbol)
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(Theme.accentDiagonal, lineWidth: 2)
                    .padding(-3)
            }

            Text(story.caption.isEmpty ? "Your story" : story.caption)
                .font(.caption2)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(1)
                .frame(width: 68)
        }
    }

    // MARK: - Stats

    private var stats: some View {
        HStack(spacing: 0) {
            statButton(value: "\(profile.postsCount)", label: "Posts") {
                tab = .posts
            }

            statDivider

            statButton(value: compact(profile.friendsCount), label: "Friends") {
                onOpenFriends()
            }

            statDivider

            statButton(value: "\(profile.followingCount)", label: "Following") {
                sheet = .following
            }
        }
        .padding(.vertical, 12)
        .glassSurface(cornerRadius: 22)
    }

    private func statButton(value: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                action()
            }
        } label: {
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .contentTransition(.numericText())

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(value) \(label)")
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(width: 1, height: 30)
    }

    private func compact(_ value: Int) -> String {
        guard value >= 1000 else { return "\(value)" }
        return String(format: "%.1fk", Double(value) / 1000)
    }

    // MARK: - Buttons

    private var buttons: some View {
        HStack(spacing: 10) {
            Button {
                sheet = .edit
            } label: {
                Text("Edit profile")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.midnight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Capsule(style: .continuous).fill(Theme.accent))
                    .shadow(color: Theme.cyan.opacity(0.35), radius: 12, y: 6)
            }
            .buttonStyle(.plain)

            Menu {
                ShareLink(item: "\(profile.name) \(profile.handle) on social.") {
                    Text("Share profile")
                }

                Button("Saved posts") {
                    sheet = .saved
                }

                Button("Verify email") {
                    sheet = .verifyEmail
                }

                Button("Two-step verification") {
                    sheet = .twoStep
                }

                Button("Discovery") {
                    sheet = .discovery
                }

                Button("Account settings") {
                    sheet = .settings
                }

                Button("Edit profile") {
                    sheet = .edit
                }

                Button("Sign out", role: .destructive) {
                    isSignOutConfirmPresented = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .frame(width: 48, height: 44)
                    .glassSurface(cornerRadius: 22)
            }
            .accessibilityLabel("Profile menu")
        }
    }

    // MARK: - Tabs

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .posts:
            postsTab
        case .photos:
            photosTab
        case .about:
            aboutTab
        }
    }

    private var profilePosts: [Post] {
        var posts = SampleProfile.posts

        if let pinned = pinnedStore.pinnedPost {
            posts.removeAll { $0.id == pinned.id }
            posts.insert(pinned, at: 0)
        }

        return posts
    }

    private var postsTab: some View {
        VStack(spacing: 14) {
            ForEach(profilePosts) { post in
                PostCardView(
                    post: post,
                    isLiked: feedStore.isLiked(post.id),
                    isPinned: pinnedStore.isPinned(post.id),
                    showsPinAction: true,
                    onTogglePin: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            pinnedStore.toggle(post)
                        }
                    }
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                        feedStore.toggleLike(post.id)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .onTapGesture {
                    onOpenPost(post)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var photosTab: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach(SampleProfile.photos) { photo in
                Button {
                    selectedPhoto = photo
                } label: {
                    ZStack {
                        LinearGradient(
                            colors: photo.media.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        Circle()
                            .fill(photo.media.glow.opacity(0.25))
                            .frame(width: 70, height: 70)
                            .blur(radius: 20)

                        Image(systemName: photo.symbol)
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(photo.caption)
            }
        }
        .padding(.horizontal, 20)
    }

    private var aboutTab: some View {
        VStack(spacing: 0) {
            aboutRow(icon: "text.alignleft", title: "Bio", value: profile.bio)

            if !profile.work.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                aboutDivider
                aboutRow(icon: "briefcase", title: "Work", value: profile.work)
            }

            aboutDivider
            aboutRow(icon: "mappin.and.ellipse", title: "Location", value: profile.location)
            aboutDivider

            Button {
                isAddressPresented = true
            } label: {
                aboutRow(icon: "house.fill", title: "Home address", value: homeAddressPreview)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open my home address")

            aboutDivider
            aboutRow(icon: "calendar", title: "Joined", value: profile.joined)
        }
        .glassSurface(cornerRadius: Theme.Radius.card)
        .padding(.horizontal, 20)
    }

    private var homeAddressPreview: String {
        let lines = addressStore.lines
        guard !lines.isEmpty else { return "" }
        guard lines.count > 1 else { return lines[0] }
        return "\(lines[0])\n\(lines[1])"
    }

    private func aboutRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Theme.tertiaryText)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var aboutDivider: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
            .padding(.leading, 56)
    }
}

// MARK: - Segmented pills

struct ProfileSegmentedControl: View {
    @Binding var selection: ProfileTab

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProfileTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = tab
                    }
                } label: {
                    Text(tab.title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(selection == tab ? Color.white : Theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selection == tab {
                                Capsule(style: .continuous)
                                    .fill(Theme.accent)
                                    .matchedGeometryEffect(id: "profileIndicator", in: indicator)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(4)
        .glassSurface(cornerRadius: 24)
    }
}

// MARK: - Full-screen photo

struct ProfilePhotoView: View {
    let photo: ProfilePhoto

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppBackground()

            VStack(spacing: 18) {
                Spacer(minLength: 0)

                ZStack {
                    LinearGradient(
                        colors: photo.media.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Circle()
                        .fill(photo.media.glow.opacity(0.25))
                        .frame(width: 240, height: 240)
                        .blur(radius: 60)

                    Image(systemName: photo.symbol)
                        .font(.system(size: 82, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.88))
                        .shadow(color: photo.media.glow.opacity(0.5), radius: 24)
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.bar, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.Radius.bar, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }

                Text(photo.caption)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            GlassIconButton(systemName: "xmark") {
                dismiss()
            }
            .padding(.trailing, 20)
            .padding(.top, 12)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Following

struct FollowingSheet: View {
    let people: [ProfilePerson]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Following")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.primaryText)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.primaryText.opacity(0.85))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.06)))
                            .overlay {
                                Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 14)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                            personRow(person)

                            if index < people.count - 1 {
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(height: 1)
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .glassSurface(cornerRadius: Theme.Radius.card)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func personRow(_ person: ProfilePerson) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: person.initials,
                palette: person.palette,
                size: 40
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(person.handle)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            Text("Following")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.06)))
                .overlay {
                    Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

#Preview {
    ProfileView(
        profileStore: ProfileStore(),
        feedStore: FeedStore(),
        savedStore: SavedPostsStore(),
        storiesStore: StoriesStore(),
        pinnedStore: PinnedPostStore()
    )
}
