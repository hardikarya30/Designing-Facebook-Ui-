//
//  MessagesView.swift
//  FacebookUI
//
//  The inbox: pinned favourites, conversations with unread counts and
//  swipe actions, and a placeholder where a thread will open.
//

import SwiftUI

struct MessagesView: View {
    @ObservedObject var store: MessagesStore
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var commentsStore: CommentsStore
    @ObservedObject var savedStore: SavedPostsStore

    @State private var searchText = ""
    @State private var openedConversation: Conversation?
    @State private var isRequestsPresented = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 0) {
                header

                searchField
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)

                conversationList
            }
        }
        .fullScreenCover(item: $openedConversation) { conversation in
            ConversationView(
                conversation: conversation,
                store: store,
                feedStore: feedStore,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
        .sheet(isPresented: $isRequestsPresented) {
            MessageRequestsView(
                store: store,
                feedStore: feedStore,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Messages")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            Menu {
                Button {
                    isSearchFocused = true
                } label: {
                    Label("New message", systemImage: "square.and.pencil")
                }

                Button {
                    isRequestsPresented = true
                } label: {
                    Label("Message requests", systemImage: "envelope.badge")
                }
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .glassSurface(cornerRadius: 22)
            }
            .accessibilityLabel("New message or message requests")
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 14)
    }

    private var subtitle: String {
        let unread = store.unreadTotal
        return unread == 0 ? "All caught up" : "\(unread) unread"
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)

            TextField("Search messages", text: $searchText)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isSearchFocused)

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

    // MARK: - Conversations

    private var filteredConversations: [Conversation] {
        let unpinned = store.conversations.filter { !store.isPinned($0) }
        guard !query.isEmpty else { return unpinned }
        return unpinned.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.preview.localizedCaseInsensitiveContains(query)
        }
    }

    private var conversationList: some View {
        List {
            if !store.pinned.isEmpty {
                pinnedSection
            }

            if filteredConversations.isEmpty {
                emptyState
                    .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filteredConversations) { conversation in
                    conversationRow(conversation)
                        .listRowInsets(EdgeInsets(top: 4, leading: 18, bottom: 4, trailing: 18))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    store.delete(conversation)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    store.toggleMute(conversation)
                                }
                            } label: {
                                Label(
                                    store.isMuted(conversation) ? "Unmute" : "Mute",
                                    systemImage: store.isMuted(conversation) ? "bell" : "bell.slash"
                                )
                            }
                            .tint(Theme.violet)

                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    store.togglePin(conversation)
                                }
                            } label: {
                                Label(
                                    store.isPinned(conversation) ? "Unpin" : "Pin",
                                    systemImage: store.isPinned(conversation) ? "pin.slash" : "pin"
                                )
                            }
                            .tint(Theme.cyan)
                        }
                }
            }

            Color.clear
                .frame(height: 24)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0)
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pinned")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Theme.tertiaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.pinned) { conversation in
                        pinnedAvatar(conversation)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 18, bottom: 14, trailing: 18))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func pinnedAvatar(_ conversation: Conversation) -> some View {
        Button {
            open(conversation)
        } label: {
            VStack(spacing: 7) {
                AvatarView(
                    initials: conversation.initials,
                    palette: conversation.palette,
                    size: 54,
                    ringWidth: 2
                )
                .overlay(alignment: .bottomTrailing) {
                    if conversation.isOnline {
                        onlineDot
                    }
                }

                Text(firstName(of: conversation.name))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }
            .frame(width: 66)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    store.togglePin(conversation)
                }
            } label: {
                Label("Unpin from inbox", systemImage: "pin.slash")
            }
        }
        .accessibilityLabel(conversation.name)
    }

    private func conversationRow(_ conversation: Conversation) -> some View {
        let isUnread = conversation.unreadCount > 0
        let isMuted = store.isMuted(conversation)

        return Button {
            open(conversation)
        } label: {
            HStack(spacing: 12) {
                AvatarView(
                    initials: conversation.initials,
                    palette: conversation.palette,
                    size: 52
                )
                .overlay(alignment: .bottomTrailing) {
                    if conversation.isOnline {
                        onlineDot
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(conversation.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)

                        if isMuted {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Theme.tertiaryText)
                        }
                    }

                    Text(conversation.preview)
                        .font(.caption)
                        .foregroundStyle(
                            isUnread ? Theme.primaryText.opacity(0.78) : Theme.secondaryText
                        )
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    Text(conversation.time)
                        .font(.caption2)
                        .foregroundStyle(isUnread ? Theme.cyan : Theme.tertiaryText)

                    if isUnread {
                        Text("\(conversation.unreadCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.midnight)
                            .frame(minWidth: 18)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Theme.cyan))
                            .contentTransition(.numericText())
                    } else {
                        Color.clear
                            .frame(height: 18)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassSurface(
                cornerRadius: 22,
                tint: isUnread ? Theme.cyan : Theme.deepBlue,
                tintOpacity: isUnread ? 0.16 : 0.42,
                shadowed: false
            )
        }
        .buttonStyle(.plain)
    }

    private var onlineDot: some View {
        Circle()
            .fill(Theme.cyan)
            .frame(width: 11, height: 11)
            .overlay {
                Circle().strokeBorder(Theme.midnight, lineWidth: 2)
            }
            .offset(x: 1, y: 1)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 64, height: 64)
                .glassSurface(cornerRadius: 32)

            Text("No results")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("No conversation matches “\(query)”.")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    private func firstName(of name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    private func open(_ conversation: Conversation) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            store.markRead(conversation)
        }
        isSearchFocused = false
        openedConversation = conversation
    }
}

// MARK: - Placeholder

#Preview {
    MessagesView(
        store: MessagesStore(),
        feedStore: FeedStore(),
        commentsStore: CommentsStore(),
        savedStore: SavedPostsStore()
    )
}
