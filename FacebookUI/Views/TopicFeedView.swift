//
//  TopicFeedView.swift
//  FacebookUI
//
//  Everything posted under one trending topic.
//

import SwiftUI

struct TopicFeedView: View {
    let topic: TrendingTopic
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var savedStore: SavedPostsStore

    @Environment(\.dismiss) private var dismiss
    @State private var isFollowing = false

    private var posts: [Post] {
        SampleTopicPosts.posts(for: topic.tag, from: feedStore.posts)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        titleBlock

                        if posts.isEmpty {
                            emptyState
                        } else {
                            ForEach(posts) { post in
                                PostCardView(
                                    post: post,
                                    isLiked: feedStore.isLiked(post.id),
                                    isSaved: savedStore.isSaved(post.id),
                                    onToggleSave: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            savedStore.toggle(post.id)
                                        }
                                    }
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                                        feedStore.toggleLike(post.id)
                                    }
                                }
                            }
                        }

                        Color.clear
                            .frame(height: 12)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var topBar: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Back")

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("#\(topic.tag)")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isFollowing.toggle()
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
                .accessibilityLabel(isFollowing ? "Unfollow #\(topic.tag)" : "Follow #\(topic.tag)")
            }

            Text("\(topic.posts) posts · trending today")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.bottom, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("#")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 68, height: 68)
                .glassSurface(cornerRadius: 34)

            Text("No posts yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Be the first to post with #\(topic.tag).")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 240)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }
}

#Preview {
    TopicFeedView(
        topic: SampleDiscover.topics[0],
        feedStore: FeedStore(),
        savedStore: SavedPostsStore()
    )
}
