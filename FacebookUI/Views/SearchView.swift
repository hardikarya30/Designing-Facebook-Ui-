//
//  SearchView.swift
//  FacebookUI
//
//  One field for everything: people, posts and topics.
//

import SwiftUI

enum SearchTab: String, CaseIterable, Identifiable {
    case people = "People"
    case posts = "Posts"
    case topics = "Topics"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct SearchView: View {
    @ObservedObject var messagesStore: MessagesStore
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var commentsStore: CommentsStore
    @ObservedObject var savedStore: SavedPostsStore

    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var tab: SearchTab = .people
    @State private var followedIDs: Set<String> = []
    @State private var destination: SearchDestination?
    @FocusState private var isSearchFocused: Bool

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    private var isSearching: Bool {
        !trimmedQuery.isEmpty
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                topBar
                SearchSegmentedControl(selection: $tab)

                ScrollView(showsIndicators: false) {
                    content
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            isSearchFocused = true
        }
        .fullScreenCover(item: $destination) { destination in
            switch destination {
            case .conversation(let conversation):
                ConversationView(
                    conversation: conversation,
                    store: messagesStore,
                    feedStore: feedStore,
                    commentsStore: commentsStore,
                    savedStore: savedStore
                )
            case .post(let post):
                PostDetailView(
                    post: post,
                    feedStore: feedStore,
                    commentsStore: commentsStore,
                    savedStore: savedStore
                )
            case .topic(let topic):
                TopicFeedView(topic: topic, feedStore: feedStore, savedStore: savedStore)
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)

                TextField("Search anything", text: $query)
                    .font(.subheadline)
                    .foregroundStyle(Theme.primaryText)
                    .tint(Theme.cyan)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isSearchFocused)

                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.tertiaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .glassSurface(cornerRadius: 20, shadowed: false)

            Button("Cancel") {
                dismiss()
            }
            .font(.subheadline)
            .foregroundStyle(Theme.secondaryText)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if isSearching {
            switch tab {
            case .people:
                peopleResults
            case .posts:
                postResults
            case .topics:
                topicResults
            }
        } else {
            recentSearches
        }
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Theme.tertiaryText)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SampleSearch.recentSearches, id: \.self) { term in
                        Button {
                            query = term
                        } label: {
                            Text(term)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.primaryText.opacity(0.85))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .glassSurface(cornerRadius: 16, shadowed: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - People

    private var filteredPeople: [SearchPerson] {
        SampleSearch.people.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.handle.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    @ViewBuilder
    private var peopleResults: some View {
        let matches = filteredPeople

        if matches.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, person in
                    personRow(person)

                    if index < matches.count - 1 {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 1)
                            .padding(.leading, 68)
                    }
                }
            }
            .glassSurface(cornerRadius: Theme.Radius.card)
            .padding(.horizontal, 16)
        }
    }

    private func personRow(_ person: SearchPerson) -> some View {
        let isFollowing = followedIDs.contains(person.id)

        return HStack(spacing: 12) {
            Button {
                destination = .conversation(conversation(for: person))
            } label: {
                HStack(spacing: 12) {
                    AvatarView(
                        initials: person.initials,
                        palette: person.palette,
                        size: 46
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(person.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)

                        Text("\(person.handle) · \(person.note)")
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if isFollowing {
                        followedIDs.remove(person.id)
                    } else {
                        followedIDs.insert(person.id)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    if isFollowing {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                    }

                    Text(isFollowing ? "Following" : "Follow")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(isFollowing ? Theme.secondaryText : Theme.cyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
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
        .padding(.vertical, 10)
    }

    private func conversation(for person: SearchPerson) -> Conversation {
        Conversation(
            id: "search-\(person.id)",
            name: person.name,
            initials: person.initials,
            palette: person.palette,
            preview: "Say hello",
            time: "Now",
            unreadCount: 0,
            isOnline: true,
            isPinned: false
        )
    }

    // MARK: - Posts

    private var filteredPosts: [Post] {
        feedStore.posts.filter {
            $0.caption.localizedCaseInsensitiveContains(trimmedQuery)
                || $0.author.name.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    @ViewBuilder
    private var postResults: some View {
        let matches = filteredPosts

        if matches.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, post in
                    postRow(post)

                    if index < matches.count - 1 {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 1)
                            .padding(.leading, 74)
                    }
                }
            }
            .glassSurface(cornerRadius: Theme.Radius.card)
            .padding(.horizontal, 16)
        }
    }

    private func postRow(_ post: Post) -> some View {
        Button {
            destination = .post(post)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    LinearGradient(
                        colors: post.media.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: post.symbol)
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.85))
                }
                .frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(post.caption)
                        .font(.subheadline)
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("\(post.likeCount.formatted()) likes · \(post.timeAgo)")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Topics

    private var filteredTopics: [TrendingTopic] {
        SampleDiscover.topics.filter {
            $0.tag.localizedCaseInsensitiveContains(trimmedQuery.replacingOccurrences(of: "#", with: ""))
        }
    }

    @ViewBuilder
    private var topicResults: some View {
        let matches = filteredTopics

        if matches.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                ForEach(Array(matches.enumerated()), id: \.element.id) { index, topic in
                    topicRow(topic)

                    if index < matches.count - 1 {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 1)
                            .padding(.leading, 62)
                    }
                }
            }
            .glassSurface(cornerRadius: Theme.Radius.card)
            .padding(.horizontal, 16)
        }
    }

    private func topicRow(_ topic: TrendingTopic) -> some View {
        Button {
            destination = .topic(topic)
        } label: {
            HStack(spacing: 12) {
                Text("#")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("#\(topic.tag)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("\(topic.posts) posts")
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open #\(topic.tag)")
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.accent)

            Text("No results")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Nothing matches “\(trimmedQuery)”.")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .glassSurface(cornerRadius: Theme.Radius.card)
        .padding(.horizontal, 16)
    }
}

// MARK: - Segmented pills

struct SearchSegmentedControl: View {
    @Binding var selection: SearchTab

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 4) {
            ForEach(SearchTab.allCases) { tab in
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
                                    .matchedGeometryEffect(id: "searchIndicator", in: indicator)
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
        .padding(.horizontal, 16)
    }
}

#Preview {
    SearchView(
        messagesStore: MessagesStore(),
        feedStore: FeedStore(),
        commentsStore: CommentsStore(),
        savedStore: SavedPostsStore()
    )
}

private enum SearchDestination: Identifiable {
    case conversation(Conversation)
    case post(Post)
    case topic(TrendingTopic)

    var id: String {
        switch self {
        case .conversation(let conversation): return "conversation-\(conversation.id)"
        case .post(let post): return "post-\(post.id)"
        case .topic(let topic): return "topic-\(topic.id)"
        }
    }
}
