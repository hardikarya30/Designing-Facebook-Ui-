//
//  ConversationView.swift
//  FacebookUI
//
//  A private conversation: bubbles, day divider, delivered ticks, the
//  message composer and the reply that comes back a moment later.
//

import Foundation
import SwiftUI

private enum ConversationVenueSheet: Identifiable {
    case picker
    case detail(Venue)

    var id: String {
        switch self {
        case .picker: return "picker"
        case .detail(let venue): return venue.id
        }
    }
}

struct ConversationView: View {
    let conversation: Conversation
    @ObservedObject var store: MessagesStore
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var commentsStore: CommentsStore
    @ObservedObject var savedStore: SavedPostsStore

    @Environment(\.dismiss) private var dismiss

    @State private var draft = ""
    @State private var isTyping = false
    @State private var replyIndex = 0
    @State private var isPostPickerPresented = false
    @State private var isAddressPresented = false
    @State private var reactingMessageID: String?
    @State private var selectedPost: Post?
    @State private var venueSheet: ConversationVenueSheet?
    @StateObject private var addressStore = AddressStore()
    @StateObject private var venuesStore = SavedVenuesStore()
    @FocusState private var isInputFocused: Bool

    private static let cannedReplies = [
        "That sounds perfect.",
        "Sending it over now.",
        "Haha yes, exactly that.",
        "Let me look and get back to you."
    ]

    private static let clock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private var messages: [Message] {
        store.messages(for: conversation.id)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header
                thread
            }
        }
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom) {
            inputBar
                .sheet(item: $venueSheet) { sheet in
                    switch sheet {
                    case .picker:
                        ShareVenueSheet { venue in
                            send(venue)
                        }
                    case .detail(let venue):
                        VenueDetailSheet(store: venuesStore, venue: venue, events: upcomingEvents(at: venue))
                    }
                }
        }
        .sheet(isPresented: $isPostPickerPresented) {
            SendPostSheet(posts: feedStore.posts) { post in
                send(post)
            }
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(
                post: post,
                feedStore: feedStore,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
        .fullScreenCover(isPresented: $isAddressPresented) {
            MyAddressView(onBack: { isAddressPresented = false })
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Back")

            AvatarView(
                initials: conversation.initials,
                palette: conversation.palette,
                size: 38
            )
            .overlay(alignment: .bottomTrailing) {
                if conversation.isOnline {
                    Circle()
                        .fill(Theme.cyan)
                        .frame(width: 10, height: 10)
                        .overlay {
                            Circle().strokeBorder(Theme.midnight, lineWidth: 2)
                        }
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(conversation.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(conversation.isOnline ? "Active now" : "Last seen recently")
                    .font(.caption2)
                    .foregroundStyle(conversation.isOnline ? Theme.cyan : Theme.secondaryText)
            }

            Spacer(minLength: 6)

            Image(systemName: "phone.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primaryText.opacity(0.85))
                .frame(width: 40, height: 40)
                .glassSurface(cornerRadius: 20)
                .accessibilityLabel("Call \(conversation.name)")

            Menu {
                Button(store.isMuted(conversation) ? "Unmute conversation" : "Mute conversation") {
                    store.toggleMute(conversation)
                }

                Button("Close") {
                    dismiss()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .glassSurface(cornerRadius: 20)
            }
            .accessibilityLabel("Conversation options")
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    // MARK: - Thread

    private var thread: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 6) {
                    if !messages.isEmpty {
                        dayDivider
                    }

                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        row(for: message, at: index)
                    }

                    if isTyping {
                        typingRow
                            .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottomLeading)))
                    }

                    Color.clear
                        .frame(height: 4)
                        .id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                scrollToBottom(proxy, animated: false)
            }
            .onChange(of: messages.count) { _, _ in
                scrollToBottom(proxy)
            }
            .onChange(of: isTyping) { _, _ in
                scrollToBottom(proxy)
            }
        }
    }

    private var dayDivider: some View {
        Text("Today, \(messages.first?.time ?? "")")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Theme.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .glassSurface(cornerRadius: 14, shadowed: false)
            .padding(.bottom, 10)
    }

    private func row(for message: Message, at index: Int) -> some View {
        let isLastInGroup = index == messages.count - 1 || messages[index + 1].isMine != message.isMine

        return HStack(alignment: .bottom, spacing: 8) {
            if message.isMine {
                Spacer(minLength: 44)
                bubble(message, isLastInGroup: isLastInGroup)
            } else {
                if isLastInGroup {
                    AvatarView(
                        initials: conversation.initials,
                        palette: conversation.palette,
                        size: 26
                    )
                } else {
                    Color.clear
                        .frame(width: 26, height: 26)
                }

                bubble(message, isLastInGroup: isLastInGroup)
                Spacer(minLength: 44)
            }
        }
        .id(message.id)
    }

    private func bubble(_ message: Message, isLastInGroup: Bool) -> some View {
        VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
            if reactingMessageID == message.id {
                reactionBar(message)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }

            Group {
                if let post = message.post {
                    postCard(post)
                } else if let address = message.address {
                    addressCard(address)
                } else if let venue = message.venue {
                    venueCard(venue)
                } else {
                    Text(message.text)
                        .font(.subheadline)
                        .foregroundStyle(message.isMine ? Color.white : Theme.primaryText.opacity(0.92))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background {
                            if message.isMine {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.cyan, Color(hex: "1D5AC4")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Theme.cyan.opacity(0.22), radius: 10, y: 5)
                            } else {
                                GlassSurface(cornerRadius: 20, tint: Theme.deepBlue, tintOpacity: 0.62)
                            }
                        }
                }
            }
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.35) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    reactingMessageID = message.id
                }
            }

            if let reaction = store.reaction(for: message.id) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        store.removeReaction(for: message.id)
                    }
                } label: {
                    Text(reaction.rawValue)
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .glassSurface(cornerRadius: 12, shadowed: false)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(reaction.name) reaction")
                .transition(.scale(scale: 0.6).combined(with: .opacity))
            }

            if isLastInGroup {
                HStack(spacing: 4) {
                    if message.isMine {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                    }

                    Text(message.time)
                }
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Theme.tertiaryText)
            }
        }
    }

    private func postCard(_ post: Post) -> some View {
        Button {
            selectedPost = post
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                postThumbnail(post)

                VStack(alignment: .leading, spacing: 3) {
                    Text(post.author.name)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)

                    Text(post.caption)
                        .font(.subheadline)
                        .foregroundStyle(Theme.primaryText.opacity(0.9))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .padding(8)
            .frame(width: 240, alignment: .leading)
            .glassSurface(cornerRadius: 20, tintOpacity: 0.6, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Sent post: \(post.caption)")
    }

    private func reactionBar(_ message: Message) -> some View {
        HStack(spacing: 4) {
            ForEach(MessageReaction.allCases) { reaction in
                Button {
                    react(reaction, with: message)
                } label: {
                    Text(reaction.rawValue)
                        .font(.system(size: 18))
                        .frame(width: 38, height: 38)
                        .background(
                            Circle().fill(
                                store.reaction(for: message.id) == reaction
                                    ? Theme.cyan.opacity(0.22)
                                    : Color.white.opacity(0.06)
                            )
                        )
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("React with \(reaction.name)")
            }
        }
        .padding(5)
        .glassSurface(cornerRadius: 24, shadowed: false)
    }

    private func react(_ reaction: MessageReaction, with message: Message) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            store.toggleReaction(reaction, for: message.id)
            reactingMessageID = nil
        }
    }

    private func addressCard(_ address: SharedAddress) -> some View {
        Button {
            isAddressPresented = true
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.cyan)

                    Text("My address")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Theme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(address.lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.primaryText.opacity(0.92))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Rectangle()
                    .fill(Theme.hairline)
                    .frame(height: 1)

                HStack(spacing: 5) {
                    Image(systemName: "map")
                        .font(.system(size: 10, weight: .semibold))
                    Text("View map")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer(minLength: 6)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(Theme.cyan)
            }
            .padding(12)
            .frame(width: 240, alignment: .leading)
            .glassSurface(cornerRadius: 20, tintOpacity: 0.6, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Shared address. View map")
    }

    private func venueCard(_ venue: Venue) -> some View {
        Button {
            venueSheet = .detail(venue)
        } label: {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 10) {
                    VenueArtwork(venue: venue)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(venue.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)

                        Text(venue.area)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(1)
                    }
                }

                Rectangle()
                    .fill(Theme.hairline)
                    .frame(height: 1)

                HStack(spacing: 5) {
                    Image(systemName: "storefront")
                        .font(.system(size: 10, weight: .semibold))
                    Text("View venue")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer(minLength: 6)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(Theme.cyan)
            }
            .padding(10)
            .frame(width: 240, alignment: .leading)
            .glassSurface(cornerRadius: 20, tintOpacity: 0.6, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Shared venue: \(venue.name). View venue")
    }

    private func postThumbnail(_ post: Post) -> some View {
        ZStack {
            if let imageName = post.imageName {
                Color.clear
                    .overlay {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                LinearGradient(
                    colors: post.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: post.symbol)
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .shadow(color: post.media.glow.opacity(0.5), radius: 14)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func send(_ post: Post) {
        store.append(
            Message(
                id: UUID().uuidString,
                text: post.caption,
                isMine: true,
                time: Self.clock.string(from: Date()),
                post: post
            ),
            to: conversation.id
        )

        respond()
    }

    private func send(_ venue: Venue) {
        store.append(
            Message(
                id: UUID().uuidString,
                text: venue.name,
                isMine: true,
                time: Self.clock.string(from: Date()),
                venue: venue
            ),
            to: conversation.id
        )

        respond()
    }

    private func upcomingEvents(at venue: Venue) -> [SocialEvent] {
        let now = Date()
        return SampleEvents.events
            .filter { event in
                event.endDate >= now
                    && venue.matchTerms.contains { term in
                        event.location.localizedCaseInsensitiveContains(term)
                    }
            }
            .sorted { $0.date < $1.date }
    }

    private var typingRow: some View {
        HStack(alignment: .bottom, spacing: 8) {
            AvatarView(
                initials: conversation.initials,
                palette: conversation.palette,
                size: 26
            )

            TypingDots()
                .padding(.horizontal, 15)
                .padding(.vertical, 13)
                .glassSurface(cornerRadius: 20, tint: Theme.deepBlue, tintOpacity: 0.62, shadowed: false)

            Spacer(minLength: 44)
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }

    // MARK: - Composer

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Menu {
                Button {
                    isPostPickerPresented = true
                } label: {
                    Label("Send a post", systemImage: "photo.on.rectangle")
                }

                Button {
                    sendAddress()
                } label: {
                    Label("Share address", systemImage: "mappin.and.ellipse")
                }

                Button {
                    venueSheet = .picker
                } label: {
                    Label("Share a venue", systemImage: "storefront")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 30, height: 30)
                    .contentShape(Circle())
            }
            .accessibilityLabel("Add an attachment")

            TextField("Message…", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .focused($isInputFocused)
                .padding(.vertical, 6)

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(canSend ? Theme.midnight : Theme.tertiaryText)
                    .frame(width: 30, height: 30)
                    .background {
                        Circle()
                            .fill(
                                canSend
                                    ? AnyShapeStyle(Theme.accent)
                                    : AnyShapeStyle(Color.white.opacity(0.06))
                            )
                    }
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .animation(.easeOut(duration: 0.2), value: canSend)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .glassSurface(cornerRadius: 26, tintOpacity: 0.6, shadowed: false)
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Sending

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        store.append(
            Message(
                id: UUID().uuidString,
                text: text,
                isMine: true,
                time: Self.clock.string(from: Date())
            ),
            to: conversation.id
        )

        draft = ""
        respond()
    }

    private func sendAddress() {
        store.append(
            Message(
                id: UUID().uuidString,
                text: "My address",
                isMine: true,
                time: Self.clock.string(from: Date()),
                address: SharedAddress(lines: addressStore.lines)
            ),
            to: conversation.id
        )

        respond()
    }

    private func respond() {
        let reply = Self.cannedReplies[replyIndex % Self.cannedReplies.count]
        replyIndex += 1

        Task {
            try? await Task.sleep(for: .milliseconds(650))

            withAnimation(.easeOut(duration: 0.2)) {
                isTyping = true
            }

            try? await Task.sleep(for: .milliseconds(1500))

            withAnimation(.easeOut(duration: 0.2)) {
                isTyping = false
            }

            store.append(
                Message(
                    id: UUID().uuidString,
                    text: reply,
                    isMine: false,
                    time: Self.clock.string(from: Date())
                ),
                to: conversation.id
            )
        }
    }
}

// MARK: - Typing dots

struct TypingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Theme.violet)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animating ? 1 : 0.6)
                    .opacity(animating ? 1 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

#Preview {
    ConversationView(
        conversation: SampleMessages.conversations[0],
        store: MessagesStore(),
        feedStore: FeedStore(),
        commentsStore: CommentsStore(),
        savedStore: SavedPostsStore()
    )
}
