//
//  FriendsView.swift
//  FacebookUI
//
//  Friends, requests and suggestions, on the app's glass surfaces.
//

import SwiftUI

enum FriendsTab: String, CaseIterable, Identifiable {
    case all
    case requests
    case suggestions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .requests: return "Requests"
        case .suggestions: return "Suggestions"
        }
    }
}

struct FriendsView: View {
    @ObservedObject var store: FriendsStore

    @State private var selection: FriendsTab = .all
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    searchField

                    FriendsSegmentedControl(
                        selection: $selection,
                        requestCount: store.requests.count
                    )

                    content

                    Color.clear
                        .frame(height: 104)
                }
                .padding(.horizontal, 18)
                .padding(.top, 2)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Friends")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private var subtitle: String {
        let friends = store.totalFriendCount.formatted()
        let count = store.requests.count
        let requests = count == 1 ? "request" : "requests"
        return "\(friends) friends · \(count) \(requests)"
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)

            TextField("Search friends", text: $searchText)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.tertiaryText)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassSurface(cornerRadius: Theme.Radius.field)
        .animation(.easeOut(duration: 0.2), value: searchText.isEmpty)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .all:
            friendsList
        case .requests:
            requestsList
        case .suggestions:
            suggestionsList
        }
    }

    // MARK: - Friends

    private var filteredFriends: [Friend] {
        guard !query.isEmpty else { return store.friends }
        return store.friends.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    @ViewBuilder
    private var friendsList: some View {
        let matches = filteredFriends

        if matches.isEmpty {
            emptyState(
                icon: query.isEmpty ? "person.2" : "magnifyingglass",
                title: query.isEmpty ? "No friends yet" : "No results",
                message: query.isEmpty
                    ? "Friends you add will show up here."
                    : "No one matches “\(query)”."
            )
        } else {
            VStack(spacing: 0) {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, friend in
                    friendRow(friend)

                    if index < matches.count - 1 {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 1)
                            .padding(.leading, 72)
                    }
                }
            }
            .glassSurface(cornerRadius: Theme.Radius.card)
        }
    }

    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: friend.initials,
                palette: friend.palette,
                size: 46
            )
            .overlay(alignment: .bottomTrailing) {
                if friend.isOnline {
                    Circle()
                        .fill(Theme.cyan)
                        .frame(width: 11, height: 11)
                        .overlay {
                            Circle().strokeBorder(Theme.midnight, lineWidth: 2)
                        }
                        .offset(x: 1, y: 1)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(friend.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(friend.status)
                    .font(.caption)
                    .foregroundStyle(friend.isOnline ? Theme.cyan : Theme.secondaryText)
            }

            Spacer(minLength: 8)

            Image(systemName: "bubble.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.white.opacity(0.06)))
                .overlay {
                    Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
                .accessibilityLabel("Message \(friend.name)")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Requests

    private var filteredRequests: [FriendRequest] {
        guard !query.isEmpty else { return store.requests }
        return store.requests.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    @ViewBuilder
    private var requestsList: some View {
        let matches = filteredRequests

        if matches.isEmpty {
            emptyState(
                icon: query.isEmpty ? "checkmark.circle" : "magnifyingglass",
                title: query.isEmpty ? "No requests right now" : "No results",
                message: query.isEmpty
                    ? "You're all caught up."
                    : "No one matches “\(query)”."
            )
        } else {
            VStack(spacing: 12) {
                ForEach(matches) { request in
                    requestCard(request)
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: .scale(scale: 0.92).combined(with: .opacity)
                            )
                        )
                }
            }
        }
    }

    private func requestCard(_ request: FriendRequest) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                AvatarView(
                    initials: request.initials,
                    palette: request.palette,
                    size: 52,
                    ringWidth: 1.5
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(request.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("\(request.mutualFriends) mutual friends")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Button("Accept") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        store.accept(request)
                    }
                }
                .buttonStyle(AcceptButtonStyle())

                Button("Decline") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        store.decline(request)
                    }
                }
                .buttonStyle(DeclineButtonStyle())
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }

    // MARK: - Suggestions

    private var filteredSuggestions: [FriendSuggestion] {
        guard !query.isEmpty else { return store.suggestions }
        return store.suggestions.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    @ViewBuilder
    private var suggestionsList: some View {
        let matches = filteredSuggestions

        if matches.isEmpty {
            emptyState(
                icon: "magnifyingglass",
                title: "No results",
                message: "No one matches “\(query)”."
            )
        } else {
            VStack(spacing: 0) {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, suggestion in
                    suggestionRow(suggestion)

                    if index < matches.count - 1 {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 1)
                            .padding(.leading, 72)
                    }
                }
            }
            .glassSurface(cornerRadius: Theme.Radius.card)
        }
    }

    private func suggestionRow(_ suggestion: FriendSuggestion) -> some View {
        let isFollowing = store.isFollowing(suggestion)

        return HStack(spacing: 12) {
            AvatarView(
                initials: suggestion.initials,
                palette: suggestion.palette,
                size: 46
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(suggestion.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(suggestion.reason)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.toggleFollow(suggestion)
                }
            } label: {
                HStack(spacing: 5) {
                    if isFollowing {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                    }

                    Text(isFollowing ? "Following" : "Follow")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(isFollowing ? Theme.secondaryText : Theme.cyan)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    Capsule(style: .continuous)
                        .fill(isFollowing ? Color.white.opacity(0.06) : Theme.cyan.opacity(0.16))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            isFollowing ? Color.white.opacity(0.12) : Theme.cyan.opacity(0.4),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    // MARK: - Shared

    private var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 64, height: 64)
                .glassSurface(cornerRadius: 32)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text(message)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 240)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }
}

// MARK: - Segmented pills

struct FriendsSegmentedControl: View {
    @Binding var selection: FriendsTab
    var requestCount: Int

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FriendsTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(tab.title)
                            .font(.footnote.weight(.semibold))

                        if tab == .requests && requestCount > 0 {
                            Text("\(requestCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .fill(Color.white.opacity(selection == tab ? 0.26 : 0.12))
                                }
                                .contentTransition(.numericText())
                        }
                    }
                    .foregroundStyle(selection == tab ? Color.white : Theme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selection == tab {
                            Capsule(style: .continuous)
                                .fill(Theme.accent)
                                .matchedGeometryEffect(id: "friendsIndicator", in: indicator)
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

// MARK: - Button styles

struct AcceptButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.midnight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                Capsule(style: .continuous)
                    .fill(Theme.accent)
            }
            .shadow(color: Theme.cyan.opacity(0.35), radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct DeclineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.primaryText.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.07))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppBackground()
        FriendsView(store: FriendsStore())
        BottomTabBar(selection: .constant(.friends))
    }
    .preferredColorScheme(.dark)
}
