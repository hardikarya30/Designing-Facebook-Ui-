//
//  PostCardView.swift
//  FacebookUI
//

import SwiftUI

struct PostCardView: View {
    let post: Post
    let isLiked: Bool
    var isMine: Bool = false
    var isSaved: Bool = false
    var isPinned: Bool = false
    var showsPinAction: Bool = false
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    var onToggleSave: () -> Void = {}
    var onTogglePin: () -> Void = {}
    var onRemoveFromSaved: (() -> Void)? = nil
    let onLike: () -> Void

    @State private var isLikersPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isPinned {
                pinnedBadge
            }
            header
            caption
            media
            footer
        }
        .padding(16)
        .glassSurface(cornerRadius: Theme.Radius.card)
        .sheet(isPresented: $isLikersPresented) {
            LikersSheet(count: post.likeCount + (isLiked ? 1 : 0))
        }
    }

    private var pinnedBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "pin.fill")
                .font(.system(size: 8, weight: .bold))

            Text("Pinned")
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundStyle(Theme.cyan)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(Theme.cyan.opacity(0.14)))
        .accessibilityLabel("Pinned to profile")
    }

    private var header: some View {
        HStack(spacing: 11) {
            AvatarView(
                initials: post.author.initials,
                palette: post.author.palette,
                size: 42
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(post.author.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(post.timeAgo)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            if isMine || showsPinAction {
                Menu {
                    if isMine {
                        Button {
                            onEdit()
                        } label: {
                            Label("Edit post", systemImage: "pencil")
                        }
                    }

                    Button {
                        onTogglePin()
                    } label: {
                        Label(
                            isPinned ? "Unpin from profile" : "Pin to profile",
                            systemImage: isPinned ? "pin.slash" : "pin"
                        )
                    }

                    if isMine {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("Delete post", systemImage: "trash")
                        }
                    }

                    if let onRemoveFromSaved {
                        Button(role: .destructive) {
                            onRemoveFromSaved()
                        } label: {
                            Label("Remove from saved", systemImage: "bookmark.slash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.primaryText.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Post options")
            } else if let onRemoveFromSaved {
                Menu {
                    Button(role: .destructive) {
                        onRemoveFromSaved()
                    } label: {
                        Label("Remove from saved", systemImage: "bookmark.slash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.primaryText.opacity(0.8))
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Saved post options")
            } else {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
                    .frame(width: 30, height: 30)
            }
        }
    }

    private var caption: some View {
        Text(post.caption)
            .font(.subheadline)
            .foregroundStyle(Theme.primaryText.opacity(0.9))
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var media: some View {
        ZStack {
            if let imageName = post.imageName {
                Color.clear
                    .overlay {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                    .overlay {
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.28)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
                    .clipped()
            } else {
                artwork
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
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

    private var artwork: some View {
        ZStack {
            LinearGradient(
                colors: post.media.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(post.media.glow.opacity(0.22))
                .frame(width: 190, height: 190)
                .blur(radius: 46)
                .offset(x: -40, y: -36)

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 130, height: 130)
                .blur(radius: 34)
                .offset(x: 78, y: 66)

            Image(systemName: post.symbol)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.white.opacity(0.85))
                .shadow(color: post.media.glow.opacity(0.55), radius: 20)
        }
    }

    private var footer: some View {
        HStack(spacing: 20) {
            HStack(spacing: 7) {
                Button(action: onLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isLiked ? Theme.rose : Theme.secondaryText)
                        .symbolEffect(.bounce, value: isLiked)
                        .frame(width: 26, height: 30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isLiked ? "Unlike post" : "Like post")

                Button {
                    isLikersPresented = true
                } label: {
                    Text("\(post.likeCount + (isLiked ? 1 : 0))")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(isLiked ? Theme.rose : Theme.secondaryText)
                        .contentTransition(.numericText())
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See who liked this post")
            }

            HStack(spacing: 7) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 14, weight: .semibold))

                Text("\(post.commentCount)")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(Theme.secondaryText)
            .padding(.vertical, 6)
            .accessibilityLabel("\(post.commentCount) comments")

            Spacer(minLength: 0)

            Button(action: onToggleSave) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSaved ? Theme.cyan : Theme.secondaryText)
                    .symbolEffect(.bounce, value: isSaved)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSaved)
            .accessibilityLabel(isSaved ? "Remove from saved" : "Save post")
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            PostCardView(post: SampleFeed.posts[0], isLiked: true, onLike: {})
            PostCardView(post: SampleFeed.posts[1], isLiked: false, onLike: {})
        }
        .padding()
    }
    .background(AppBackground())
}
