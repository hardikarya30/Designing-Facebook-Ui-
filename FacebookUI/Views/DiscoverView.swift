//
//  DiscoverView.swift
//  FacebookUI
//
//  Explore: trending topics, a masonry grid of glass artwork, people to
//  follow, and a full-screen look at any post in the grid.
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var store: DiscoverStore
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var savedStore: SavedPostsStore

    @State private var searchText = ""
    @State private var destination: DiscoverDestination?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        searchField

                        if !filteredTopics.isEmpty {
                            trends
                        }

                        if filteredTiles.isEmpty && filteredPeople.isEmpty {
                            emptyState
                        } else {
                            tileSection
                            peopleSection
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .fullScreenCover(item: $destination) { destination in
            switch destination {
            case .tile(let tile):
                PostPreviewView(tile: tile, store: store)
            case .topic(let topic):
                TopicFeedView(topic: topic, feedStore: feedStore, savedStore: savedStore)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Discover")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text("Find people, topics and posts")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 14)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)

            TextField("Search people, posts, topics", text: $searchText)
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

    // MARK: - Trending

    private var filteredTopics: [TrendingTopic] {
        guard !query.isEmpty else { return store.topics }
        return store.topics.filter { $0.tag.localizedCaseInsensitiveContains(query) }
    }

    private var trends: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending now")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filteredTopics) { topic in
                        trendChip(topic)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func trendChip(_ topic: TrendingTopic) -> some View {
        Button {
            destination = .topic(topic)
        } label: {
            HStack(spacing: 8) {
                Text("#\(topic.tag)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))

                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Theme.cyan)

                    Text(topic.posts)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .glassSurface(cornerRadius: 18, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open #\(topic.tag)")
    }

    // MARK: - Explore grid

    private var filteredTiles: [ExploreTile] {
        guard !query.isEmpty else { return store.tiles }
        return store.tiles.filter {
            $0.category.localizedCaseInsensitiveContains(query)
                || $0.caption.localizedCaseInsensitiveContains(query)
        }
    }

    private var leftTiles: [ExploreTile] {
        let tiles = filteredTiles
        return tiles.enumerated()
            .filter { $0.offset.isMultiple(of: 2) }
            .map { $0.element }
    }

    private var rightTiles: [ExploreTile] {
        let tiles = filteredTiles
        return tiles.enumerated()
            .filter { !$0.offset.isMultiple(of: 2) }
            .map { $0.element }
    }

    @ViewBuilder
    private var tileSection: some View {
        if !filteredTiles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Explore")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.primaryText)

                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 12) {
                        ForEach(leftTiles) { tile in
                            tileCard(tile)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 12) {
                        ForEach(rightTiles) { tile in
                            tileCard(tile)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func tileCard(_ tile: ExploreTile) -> some View {
        Button {
            destination = .tile(tile)
        } label: {
            ZStack {
                LinearGradient(
                    colors: tile.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(tile.media.glow.opacity(0.24))
                    .frame(width: 150, height: 150)
                    .blur(radius: 42)
                    .offset(x: -30, y: -30)

                Image(systemName: tile.symbol)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .shadow(color: tile.media.glow.opacity(0.5), radius: 18)
            }
            .frame(maxWidth: .infinity)
            .frame(height: tile.height)
            .overlay(alignment: .topTrailing) {
                likeBadge(tile)
                    .padding(9)
            }
            .overlay(alignment: .bottomLeading) {
                categoryBadge(tile)
                    .padding(9)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tile.category): \(tile.caption)")
    }

    private func likeBadge(_ tile: ExploreTile) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.system(size: 8, weight: .bold))

            Text(tile.likeCount.formatted())
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundStyle(Color.white.opacity(0.92))
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule().fill(Color.black.opacity(0.18))
                }
        }
    }

    private func categoryBadge(_ tile: ExploreTile) -> some View {
        Text(tile.category)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.92))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule().fill(Color.black.opacity(0.18))
                    }
            }
    }

    // MARK: - People

    private var filteredPeople: [DiscoverPerson] {
        guard !query.isEmpty else { return store.people }
        return store.people.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.reason.localizedCaseInsensitiveContains(query)
        }
    }

    @ViewBuilder
    private var peopleSection: some View {
        if !filteredPeople.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("People you may know")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.primaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filteredPeople) { person in
                            personCard(person)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func personCard(_ person: DiscoverPerson) -> some View {
        let isFollowing = store.isFollowing(person)

        return VStack(alignment: .leading, spacing: 10) {
            AvatarView(
                initials: person.initials,
                palette: person.palette,
                size: 58
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(person.reason)
                    .font(.caption2)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(2)
            }
            .frame(height: 34, alignment: .topLeading)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    store.toggleFollow(person)
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
                .frame(maxWidth: .infinity)
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
        .padding(14)
        .frame(width: 158, alignment: .leading)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }

    // MARK: - Shared

    private var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
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

            Text("Nothing matches “\(query)”.")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }
}

// MARK: - Full-screen post preview

private enum DiscoverDestination: Identifiable {
    case tile(ExploreTile)
    case topic(TrendingTopic)

    var id: String {
        switch self {
        case .tile(let tile): return "tile-\(tile.id)"
        case .topic(let topic): return "topic-\(topic.id)"
        }
    }
}

struct PostPreviewView: View {
    let tile: ExploreTile
    @ObservedObject var store: DiscoverStore

    @Environment(\.dismiss) private var dismiss

    private var isLiked: Bool {
        store.isLiked(tile)
    }

    private var likeCount: Int {
        tile.likeCount + (isLiked ? 1 : 0)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    media

                    HStack(spacing: 10) {
                        Text(tile.category)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Theme.cyan)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background {
                                Capsule().fill(Theme.cyan.opacity(0.14))
                            }

                        Spacer()

                        Text(tile.timeAgo)
                            .font(.caption)
                            .foregroundStyle(Theme.secondaryText)
                    }

                    Text(tile.caption)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    authorRow

                    actions
                }
                .padding(.horizontal, 20)
                .padding(.top, 66)
                .padding(.bottom, 40)
            }

            GlassIconButton(systemName: "xmark") {
                dismiss()
            }
            .padding(.trailing, 20)
            .padding(.top, 12)
        }
        .preferredColorScheme(.dark)
    }

    private var media: some View {
        ZStack {
            LinearGradient(
                colors: tile.media.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(tile.media.glow.opacity(0.24))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -60, y: -50)

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 170, height: 170)
                .blur(radius: 44)
                .offset(x: 90, y: 80)

            Image(systemName: tile.symbol)
                .font(.system(size: 92, weight: .light))
                .foregroundStyle(Color.white.opacity(0.88))
                .shadow(color: tile.media.glow.opacity(0.55), radius: 26)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
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
    }

    private var authorRow: some View {
        HStack(spacing: 11) {
            AvatarView(
                initials: tile.initials,
                palette: tile.palette,
                size: 42
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(tile.author)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text("Creator")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 0)
        }
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                    store.toggleLike(tile)
                }
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .semibold))
                        .symbolEffect(.bounce, value: isLiked)

                    Text(likeCount.formatted())
                        .font(.footnote.weight(.semibold))
                        .contentTransition(.numericText())
                }
                .foregroundStyle(isLiked ? Theme.rose : Theme.primaryText.opacity(0.85))
                .padding(.horizontal, 15)
                .padding(.vertical, 11)
                .background {
                    Capsule(style: .continuous)
                        .fill(isLiked ? Theme.rose.opacity(0.14) : Color.white.opacity(0.06))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            isLiked ? Theme.rose.opacity(0.35) : Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isLiked ? "Unlike" : "Like")

            HStack(spacing: 7) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 13, weight: .semibold))

                Text(tile.commentCount.formatted())
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(Theme.primaryText.opacity(0.85))
            .padding(.horizontal, 15)
            .padding(.vertical, 11)
            .background {
                Capsule(style: .continuous).fill(Color.white.opacity(0.06))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            }
            .accessibilityLabel("\(tile.commentCount) comments")

            Spacer(minLength: 0)

            ShareLink(item: "\(tile.caption) — \(tile.category) on social.") {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .frame(width: 42, height: 42)
                    .glassSurface(cornerRadius: 21)
            }
            .accessibilityLabel("Share post")
        }
    }
}

#Preview {
    DiscoverView(store: DiscoverStore(), feedStore: FeedStore(), savedStore: SavedPostsStore())
}
