//
//  SideBarView.swift
//  FacebookUI
//
//  Navigation, shortcuts, support, settings and upgrades in the app menu.
//

import SwiftUI

private struct SidebarShortcut: Identifiable {
    let title: String
    let icon: String

    var id: String { title }

    static let all = [
        SidebarShortcut(title: "Meta AI", icon: "sparkles"),
        SidebarShortcut(title: "Saved", icon: "bookmark.fill"),
        SidebarShortcut(title: "Memories", icon: "clock.arrow.circlepath"),
        SidebarShortcut(title: "BALLO DOI", icon: "star.fill"),
        SidebarShortcut(title: "Marketplace", icon: "storefront.fill"),
        SidebarShortcut(title: "Avatars", icon: "face.smiling"),
        SidebarShortcut(title: "畄", icon: "square.grid.2x2.fill"),
        SidebarShortcut(title: "Birthdays", icon: "gift.fill"),
        SidebarShortcut(title: "Chat with AIs", icon: "bubble.left.and.bubble.right.fill"),
        SidebarShortcut(title: "Events", icon: "calendar"),
        SidebarShortcut(title: "My address", icon: "map.fill"),
        SidebarShortcut(title: "Discounts", icon: "tag.fill"),
        SidebarShortcut(title: "Feeds", icon: "rectangle.stack.fill"),
        SidebarShortcut(title: "Finds", icon: "safari.fill"),
        SidebarShortcut(title: "Friends", icon: "person.2.fill"),
        SidebarShortcut(title: "Games", icon: "gamecontroller.fill"),
        SidebarShortcut(title: "Groups", icon: "person.3.fill"),
        SidebarShortcut(title: "Pokes", icon: "hand.wave.fill"),
        SidebarShortcut(title: "Reels", icon: "play.rectangle.fill")
    ]
}

private enum SidebarSheet: Identifiable {
    case saved
    case settings
    case messages
    case discover
    case adPreferences
    case metaPay
    case publicPresence
    case facebookPlus
    case metaCore
    case information(title: String, message: String)

    var id: String {
        switch self {
        case .saved: return "saved"
        case .settings: return "settings"
        case .messages: return "messages"
        case .discover: return "discover"
        case .adPreferences: return "adPreferences"
        case .metaPay: return "metaPay"
        case .publicPresence: return "publicPresence"
        case .facebookPlus: return "facebookPlus"
        case .metaCore: return "metaCore"
        case .information(let title, _): return "information-\(title)"
        }
    }

    var isLarge: Bool {
        if case .information = self { return false }
        return true
    }
}

struct SideBarView: View {
    let accountName: String
    let accountEmail: String
    let accountPhone: String
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var savedStore: SavedPostsStore
    @ObservedObject var storiesStore: StoriesStore
    @ObservedObject var messagesStore: MessagesStore
    @ObservedObject var commentsStore: CommentsStore
    @ObservedObject var discoverStore: DiscoverStore
    let onSelectTab: (AppTab) -> Void
    let onOpenGroups: () -> Void
    let onOpenMarketplace: () -> Void
    let onOpenMemories: () -> Void
    let onOpenEvents: () -> Void
    let onOpenAddress: () -> Void
    let onOpenDiscounts: () -> Void
    let onSignOut: () -> Void
    let onChangePassword: (String, String) -> Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var isShowingAllShortcuts = true
    @State private var isHelpExpanded = false
    @State private var isSettingsExpanded = false
    @State private var isUpgradesExpanded = false
    @State private var isSignOutConfirmPresented = false
    @State private var selectedSheet: SidebarSheet?

    private var displayName: String {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == "Alex Morgan" ? "Hardik Arya" : trimmed
    }

    private var displayEmail: String {
        let trimmed = accountEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Your profile" : trimmed
    }

    private var visibleShortcuts: [SidebarShortcut] {
        isShowingAllShortcuts ? SidebarShortcut.all : Array(SidebarShortcut.all.prefix(8))
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    profileCard
                    primaryNavigation
                    shortcutsSection
                    helpSection
                    settingsSection
                    upgradesSection
                    signOutButton
                        .padding(.top, 2)

                    Color.clear.frame(height: 12)
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedSheet) { destination in
            sheetContent(for: destination)
                .presentationDetents(destination.isLarge ? [.large] : [.medium, .large])
                .presentationDragIndicator(destination.isLarge ? .hidden : .visible)
        }
        .confirmationDialog(
            "Log out of FacebookUI?",
            isPresented: $isSignOutConfirmPresented,
            titleVisibility: .visible
        ) {
            Button("Log out", role: .destructive) {
                dismiss()
                onSignOut()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your profile and saved posts stay on this device.")
        }
    }

    private var header: some View {
        HStack {
            Text("Menu")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Spacer()

            GlassIconButton(systemName: "xmark", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Close menu")
        }
    }

    private var profileCard: some View {
        HStack(spacing: 12) {
            ProfilePictureView(size: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(displayEmail)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)
        }
        .padding(14)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.62)
    }

    private var primaryNavigation: some View {
        VStack(spacing: 0) {
            primaryRow("Home", icon: "house.fill") {
                selectTab(.home)
            }
            sidebarDivider
            primaryRow("Profile", icon: "person.crop.circle.fill") {
                selectTab(.profile)
            }
            sidebarDivider
            primaryRow("Group", icon: "person.3.fill") {
                openGroups()
            }
        }
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.52)
    }

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR SHORTCUTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(2.5)
                .foregroundStyle(Theme.tertiaryText)
                .padding(.leading, 3)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(visibleShortcuts) { shortcut in
                    Button {
                        openShortcut(shortcut)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: shortcut.icon)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Theme.cyan)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Theme.cyan.opacity(0.1)))

                            Text(shortcut.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.primaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .padding(.horizontal, 10)
                        .glassSurface(cornerRadius: 18, tintOpacity: 0.48)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
                    isShowingAllShortcuts.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isShowingAllShortcuts ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                    Text(isShowingAllShortcuts ? "See less" : "See more")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(20)
                .glassSurface(cornerRadius: 18, tintOpacity: 0.42)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isShowingAllShortcuts ? "See less shortcuts" : "See more shortcuts")
        }
    }

    private var helpSection: some View {
        expandableSection(
            title: "Help and support",
            icon: "questionmark.circle.fill",
            isExpanded: $isHelpExpanded
        ) {
            VStack(spacing: 0) {
                expandableRow("Meta AI support assistant", icon: "sparkles")
                sidebarDivider
                expandableRow("Scam Protection Centre", icon: "hand.raised.fill")
                sidebarDivider
                expandableRow("Support", icon: "questionmark.circle")
                sidebarDivider
                expandableRow("Report a problem", icon: "exclamationmark.bubble")
                sidebarDivider
                expandableRow("Terms and policies", icon: "doc.text")
            }
        }
    }

    private var settingsSection: some View {
        expandableSection(
            title: "Settings and privacy",
            icon: "slider.horizontal.3",
            isExpanded: $isSettingsExpanded
        ) {
            VStack(spacing: 0) {
                expandableRow("Settings", icon: "gearshape") {
                    selectedSheet = .settings
                }
                sidebarDivider
                expandableRow("Privacy Centre", icon: "hand.raised")
                sidebarDivider
                expandableRow("Time management", icon: "hourglass")
                sidebarDivider
                expandableRow("Device requests", icon: "iphone.and.arrow.forward")
                sidebarDivider
                expandableRow("Your ad activity", icon: "rectangle.on.rectangle") {
                    selectedSheet = .adPreferences
                }
                sidebarDivider
                expandableRow("Orders and payments", icon: "creditcard") {
                    selectedSheet = .metaPay
                }
                sidebarDivider
                expandableRow("Link history", icon: "link")
                sidebarDivider
                expandableRow("Dark Mode", icon: "moon.fill") {
                    showInformation("Dark Mode", message: "FacebookUI currently uses its midnight dark appearance.")
                }
                sidebarDivider
                expandableRow("App language", icon: "character.bubble")
                sidebarDivider
                expandableRow("App icon", icon: "app.dashed")
                sidebarDivider
                expandableRow("Mobile data use", icon: "antenna.radiowaves.left.and.right")
            }
        }
    }

    private var upgradesSection: some View {
        expandableSection(
            title: "Upgrades",
            icon: "sparkles",
            isExpanded: $isUpgradesExpanded
        ) {
            VStack(spacing: 12) {
                PublicPresenceCard {
                    selectedSheet = .publicPresence
                }

                FacebookPlusCard {
                    selectedSheet = .facebookPlus
                }

                MetaCoreCard {
                    selectedSheet = .metaCore
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Explore more from Meta")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.8)
                        .foregroundStyle(Theme.tertiaryText)
                        .padding(.leading, 3)

                    serviceCard(
                        title: "Meta AI",
                        subtitle: "Get answers, create anything",
                        icon: "sparkles",
                        tint: Theme.cyan
                    ) {
                        openMetaAI()
                    }

                    serviceCard(
                        title: "WhatsApp",
                        subtitle: "Message and call privately",
                        icon: "message.fill",
                        tint: Color(hex: "55D98A")
                    ) {
                        openWebsite("https://www.whatsapp.com", title: "WhatsApp")
                    }

                    serviceCard(
                        title: "Edits",
                        subtitle: "Create and edit videos",
                        icon: "video.fill",
                        tint: Theme.violet
                    ) {
                        showInformation("Edits", message: "Edits is shown here as a shortcut. The separate app is not connected to this demo.")
                    }

                    serviceCard(
                        title: "Threads",
                        subtitle: "Join the conversation",
                        icon: "at",
                        tint: Color(hex: "E7E9EF")
                    ) {
                        openWebsite("https://www.threads.net", title: "Threads")
                    }

                    serviceCard(
                        title: "Instagram",
                        subtitle: "Share moments with friends",
                        icon: "camera.fill",
                        tint: Color(hex: "F28CB8")
                    ) {
                        openWebsite("https://www.instagram.com", title: "Instagram")
                    }
                }
                .padding(14)
                .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.44)
            }
        }
    }

    private var signOutButton: some View {
        Button {
            isSignOutConfirmPresented = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Log out")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(Theme.rose)
            .padding(20)
            .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.38)
        }
        .buttonStyle(.plain)
    }

    private func primaryRow(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 30, height: 30)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func expandableSection<Content: View>(
        title: String,
        icon: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .frame(width: 30, height: 30)

                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Spacer()

                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded.wrappedValue {
                content()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.5)
    }

    private func expandableRow(
        _ title: String,
        icon: String,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            if let action {
                action()
            } else {
                showInformation(title, message: "This option is listed in the menu. Its dedicated screen is not connected in this demo.")
            }
        } label: {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func serviceCard(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(tint.opacity(0.12)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tintOpacity: 0.42)
        }
        .buttonStyle(.plain)
    }

    private var sidebarDivider: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
            .padding(.leading, 56)
            .padding(.trailing, 14)
    }

    @ViewBuilder
    private func sheetContent(for destination: SidebarSheet) -> some View {
        switch destination {
        case .saved:
            SavedPostsView(savedStore: savedStore, feedStore: feedStore)
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
        case .messages:
            MessagesView(
                store: messagesStore,
                feedStore: feedStore,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        case .discover:
            DiscoverView(store: discoverStore, feedStore: feedStore, savedStore: savedStore)
        case .adPreferences:
            AdPreferencesView()
        case .metaPay:
            MetaPayView()
        case .publicPresence:
            PublicPresenceView()
        case .facebookPlus:
            FacebookPlusSheet()
        case .metaCore:
            MetaCoreSheet()
        case .information(let title, let message):
            SidebarInfoSheet(title: title, message: message)
        }
    }

    private func openShortcut(_ shortcut: SidebarShortcut) {
        switch shortcut.title {
        case "Meta AI":
            openMetaAI()
        case "Saved":
            selectedSheet = .saved
        case "Groups":
            openGroups()
        case "Marketplace":
            openMarketplace()
        case "Memories":
            openMemories()
        case "Events":
            openEvents()
        case "My address":
            dismiss()
            onOpenAddress()
        case "Discounts":
            dismiss()
            onOpenDiscounts()
        case "Chat with AIs":
            selectedSheet = .messages
        case "Finds":
            selectedSheet = .discover
        case "Friends":
            selectTab(.friends)
        default:
            showInformation(shortcut.title, message: "This shortcut is part of your menu. Its dedicated screen is not connected in this demo.")
        }
    }

    private func openGroups() {
        dismiss()
        onOpenGroups()
    }

    private func openMarketplace() {
        dismiss()
        onOpenMarketplace()
    }

    private func openMemories() {
        dismiss()
        onOpenMemories()
    }

    private func openEvents() {
        dismiss()
        onOpenEvents()
    }

    private func selectTab(_ tab: AppTab) {
        onSelectTab(tab)
        dismiss()
    }

    private func showInformation(_ title: String, message: String) {
        selectedSheet = .information(title: title, message: message)
    }

    private func openMetaAI() {
        openWebsite("https://www.meta.ai", title: "Meta AI")
    }

    private func openWebsite(_ urlString: String, title: String) {
        guard let url = URL(string: urlString) else {
            showInformation(title, message: "This destination isn't available right now.")
            return
        }
        openURL(url)
    }
}

private struct PublicPresenceCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Theme.accent))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Public presence")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.primaryText)
                    Text("Get tools to help you grow on Facebook")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(14)
            .glassSurface(cornerRadius: 22, tintOpacity: 0.66)
        }
        .buttonStyle(.plain)
    }
}

private struct FacebookPlusCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Theme.cyan.opacity(0.14)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Facebook Plus")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.primaryText)
                        Text("Unlock exclusive features and more.")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.tertiaryText)
                }

                Text("Hardik Arya, try Facebook Plus free for one week")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text("£2.99/month • Price may include taxes")
                        .font(.caption2)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer(minLength: 4)
                    Text("Try for £0.00")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.midnight)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Theme.accent))
                }
            }
            .padding(14)
            .glassSurface(cornerRadius: 22, tintOpacity: 0.68)
        }
        .buttonStyle(.plain)
    }
}

private struct MetaCoreCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    brandMark("sparkles", title: "Meta AI", tint: Theme.cyan)
                    brandMark("person.2.fill", title: "Facebook", tint: Color(hex: "68A5FF"))
                    brandMark("message.fill", title: "WhatsApp", tint: Color(hex: "55D98A"))
                }

                Text("Get more features for less")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Text("Unlock more AI usage, added customisation, messaging features and more across Meta.")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Save with Meta Core")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                    .overlay { Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 1) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .glassSurface(cornerRadius: 22, tintOpacity: 0.62)
        }
        .buttonStyle(.plain)
    }

    private func brandMark(_ icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.white.opacity(0.05)))
    }
}

private struct PublicPresenceView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("sidebar.professionalMode") private var isProfessionalMode = false
    @State private var isHelpPresented = false
    @State private var isPageNoticePresented = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        GlassIconButton(systemName: "chevron.left", size: 40) {
                            dismiss()
                        }
                        .accessibilityLabel("Back to menu")

                        Spacer()
                    }

                    Text("Grow public presence")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Text("How do you want to get started:")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)

                    professionalModeCard
                    createPageCard

                    Button("Need help with choosing?") {
                        isHelpPresented = true
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.cyan)
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isHelpPresented) {
            SidebarInfoSheet(
                title: "Choose how to grow",
                message: "Professional mode adds audience and creator tools to your existing profile. A Page creates a separate presence for a business, brand or organisation."
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Page creation isn't connected", isPresented: $isPageNoticePresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can use the public presence menu to learn about creating a Page.")
        }
    }

    private var professionalModeCard: some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                isProfessionalMode.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "person.crop.square.badge.checkmark")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text("1 · Use professional mode")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.primaryText)
                        Spacer(minLength: 0)
                        if isProfessionalMode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.cyan)
                        }
                    }
                    Text("Add tools to your main profile to grow your public presence.")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(15)
            .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.58)
        }
        .buttonStyle(.plain)
    }

    private var createPageCard: some View {
        Button {
            isPageNoticePresented = true
        } label: {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "doc.text.image")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(Theme.violet)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.violet.opacity(0.14)))

                VStack(alignment: .leading, spacing: 7) {
                    Text("2 · Create a new Page")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.primaryText)
                    Text("Create a new presence to grow your business, personal brand or organisation.")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(15)
            .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.58)
        }
        .buttonStyle(.plain)
    }
}

private struct FacebookPlusSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isTrialNoticePresented = false

    private let benefits = [
        "Customise your app icon with a new design",
        "Send super hearts to stories that you really love",
        "See how many times your story was rewatched",
        "Preview stories without appearing on the viewer list",
        "Extend your story expiry to 48 hours",
        "Search exactly who's viewing your story using a search bar"
    ]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.cyan)
                        Text("Facebook Plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Theme.primaryText)
                        Spacer()
                        GlassIconButton(systemName: "xmark", size: 36) {
                            dismiss()
                        }
                        .accessibilityLabel("Close")
                    }

                    Text("Hardik Arya, try Facebook Plus free for one week")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Unlock exclusive features.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)

                    Text("£2.99/month • Price may include taxes")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.secondaryText)

                    Text("Available on Facebook and Messenger")
                        .font(.caption)
                        .foregroundStyle(Theme.tertiaryText)

                    VStack(alignment: .leading, spacing: 13) {
                        ForEach(benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Theme.cyan)
                                Text(benefit)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.5)

                    Button {
                        isTrialNoticePresented = true
                    } label: {
                        Text("Try for £0.00")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.midnight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(Theme.accent))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Facebook Plus", isPresented: $isTrialNoticePresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Subscription setup isn't connected in this demo.")
        }
    }
}

private struct MetaCoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isUnavailablePresented = false

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Meta Core")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                    Spacer()
                    GlassIconButton(systemName: "xmark", size: 36) {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }

                HStack(spacing: 8) {
                    metaBrand("sparkles", "Meta AI", Theme.cyan)
                    metaBrand("person.2.fill", "Facebook", Color(hex: "68A5FF"))
                    metaBrand("message.fill", "WhatsApp", Color(hex: "55D98A"))
                }

                Text("Get more features for less")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Text("Unlock more AI usage, added customisation, messaging features and more across Meta.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .lineSpacing(4)

                Spacer(minLength: 0)

                Button {
                    isUnavailablePresented = true
                } label: {
                    Text("Save with Meta Core")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .glassSurface(cornerRadius: Theme.Radius.bar)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
        .alert("Meta Core", isPresented: $isUnavailablePresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Meta Core subscription setup isn't connected in this demo.")
        }
    }

    private func metaBrand(_ icon: String, _ title: String, _ tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(title)
                .foregroundStyle(Theme.secondaryText)
        }
        .font(.system(size: 10, weight: .semibold))
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(Capsule().fill(Color.white.opacity(0.05)))
    }
}

private struct SidebarInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let message: String

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(title)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                    Spacer()
                    GlassIconButton(systemName: "xmark", size: 36) {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SideBarView(
        accountName: "Hardik Arya Arya",
        accountEmail: "alex@example.com",
        accountPhone: "+44 7700 900123",
        feedStore: FeedStore(),
        savedStore: SavedPostsStore(),
        storiesStore: StoriesStore(),
        messagesStore: MessagesStore(),
        commentsStore: CommentsStore(),
        discoverStore: DiscoverStore(),
        onSelectTab: { _ in },
        onOpenGroups: {},
        onOpenMarketplace: {},
        onOpenMemories: {},
        onOpenEvents: {},
        onOpenAddress: {},
        onOpenDiscounts: {},
        onSignOut: {},
        onChangePassword: { _, _ in false }
    )
}
