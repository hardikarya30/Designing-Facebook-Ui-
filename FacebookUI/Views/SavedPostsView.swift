//
//  SavedPostsView.swift
//  FacebookUI
//
//  Everything you bookmarked, newest saved first.
//

import SwiftUI

struct SavedPostsView: View {
    @ObservedObject var savedStore: SavedPostsStore
    @ObservedObject var feedStore: FeedStore

    @Environment(\.dismiss) private var dismiss

    private var posts: [Post] {
        savedStore.savedPosts(from: feedStore.posts)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        if posts.isEmpty {
                            emptyState
                        } else {
                            ForEach(posts) { post in
                                PostCardView(
                                    post: post,
                                    isLiked: feedStore.isLiked(post.id),
                                    isMine: feedStore.isMine(post),
                                    isSaved: true,
                                    onEdit: {},
                                    onDelete: {},
                                    onToggleSave: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            savedStore.remove(post.id)
                                        }
                                    },
                                    onRemoveFromSaved: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            savedStore.remove(post.id)
                                        }
                                    }
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                                        feedStore.toggleLike(post.id)
                                    }
                                }
                                .transition(.scale(scale: 0.92).combined(with: .opacity))
                            }
                        }

                        Color.clear
                            .frame(height: 8)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        ZStack {
            Text("Saved")
                .font(.headline)
                .foregroundStyle(Theme.primaryText)

            HStack {
                GlassIconButton(systemName: "chevron.left", size: 40) {
                    dismiss()
                }
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 68, height: 68)
                .glassSurface(cornerRadius: 34)

            Text("Nothing saved yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Tap the bookmark on a post to keep it here.")
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
    SavedPostsView(savedStore: SavedPostsStore(), feedStore: FeedStore())
}
