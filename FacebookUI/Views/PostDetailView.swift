//
//  PostDetailView.swift
//  FacebookUI
//
//  One post, larger: artwork, actions, the comment thread and a composer.
//

import SwiftUI

private enum CommentSheet: Identifiable {
    case likers
    case edit(PostComment)

    var id: String {
        switch self {
        case .likers: return "likers"
        case .edit(let comment): return "edit-\(comment.id)"
        }
    }
}

struct PostDetailView: View {
    let post: Post
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var commentsStore: CommentsStore
    @ObservedObject var savedStore: SavedPostsStore

    @Environment(\.dismiss) private var dismiss

    @State private var draft = ""
    @State private var lastAddedID: String?
    @State private var commentSheet: CommentSheet?
    @FocusState private var isComposerFocused: Bool

    private var comments: [PostComment] {
        commentsStore.comments(for: post.id)
    }

    private var isLiked: Bool {
        feedStore.isLiked(post.id)
    }

    private var likeCount: Int {
        post.likeCount + (isLiked ? 1 : 0)
    }

    private var commentCount: Int {
        max(
            0,
            post.commentCount
                + commentsStore.addedCount(for: post.id)
                - commentsStore.deletedCount(for: post.id)
        )
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            authorRow
                            caption
                            artwork
                            actions

                            Rectangle()
                                .fill(Theme.hairline)
                                .frame(height: 1)
                                .padding(.top, 4)

                            commentsHeader

                            ForEach(comments) { comment in
                                commentRow(comment)
                                    .id(comment.id)
                            }

                            Color.clear
                                .frame(height: 4)
                                .id("commentsBottom")
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                        .padding(.bottom, 14)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: comments.count) { _, _ in
                        guard let last = comments.last else { return }
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom) {
            composer
        }
        .sheet(item: $commentSheet) { sheet in
            switch sheet {
            case .likers:
                LikersSheet(count: likeCount)
            case .edit(let comment):
                EditCommentSheet(comment: comment) { text in
                    commentsStore.update(text, commentID: comment.id, postID: post.id)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Post")
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
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    // MARK: - Post

    private var authorRow: some View {
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

            Image(systemName: "ellipsis")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.tertiaryText)
                .frame(width: 30, height: 30)
        }
    }

    private var caption: some View {
        Text(post.caption)
            .font(.subheadline)
            .foregroundStyle(Theme.primaryText.opacity(0.9))
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var artwork: some View {
        ZStack {
            if let imageName = post.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipped()
            } else {
                LinearGradient(
                    colors: post.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(post.media.glow.opacity(0.24))
                    .frame(width: 240, height: 240)
                    .blur(radius: 60)
                    .offset(x: -50, y: -40)

                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .offset(x: 90, y: 70)

                Image(systemName: post.symbol)
                    .font(.system(size: 90, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .shadow(color: post.media.glow.opacity(0.55), radius: 26)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
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

    private var actions: some View {
        HStack(spacing: 18) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                    feedStore.toggleLike(post.id)
                }
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isLiked ? Theme.rose : Theme.primaryText.opacity(0.85))
                    .symbolEffect(.bounce, value: isLiked)
                    .frame(width: 28, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isLiked ? "Unlike post" : "Like post")

            Button {
                commentSheet = .likers
            } label: {
                Text(likeCount.formatted())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(isLiked ? Theme.rose : Theme.primaryText.opacity(0.85))
                    .contentTransition(.numericText())
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("See who liked this post")

            HStack(spacing: 7) {
                Image(systemName: "bubble.left")
                    .font(.system(size: 15, weight: .semibold))

                Text(commentCount.formatted())
                    .font(.footnote.weight(.semibold))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(Theme.primaryText.opacity(0.85))
            .padding(.vertical, 6)
            .accessibilityLabel("\(commentCount) comments")

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    savedStore.toggle(post.id)
                }
            } label: {
                Image(systemName: savedStore.isSaved(post.id) ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        savedStore.isSaved(post.id) ? Theme.cyan : Theme.primaryText.opacity(0.85)
                    )
                    .symbolEffect(.bounce, value: savedStore.isSaved(post.id))
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(savedStore.isSaved(post.id) ? "Remove from saved" : "Save post")

            Spacer(minLength: 0)

            ShareLink(item: "\(post.author.name) on social: \(post.caption)") {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Share post")
        }
    }

    // MARK: - Comments

    private var commentsHeader: some View {
        HStack(spacing: 8) {
            Text("COMMENTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Theme.tertiaryText)

            Text("\(commentCount.formatted())")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Capsule().fill(Theme.cyan.opacity(0.15)))

            Spacer(minLength: 0)
        }
        .padding(.top, 2)
    }

    private func commentRow(_ comment: PostComment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(
                initials: comment.author.initials,
                palette: comment.author.palette,
                size: 32
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(comment.author.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text(comment.time)
                        .font(.caption2)
                        .foregroundStyle(Theme.tertiaryText)

                    Spacer(minLength: 0)

                    if comment.author == .me {
                        Menu {
                            Button {
                                commentSheet = .edit(comment)
                            } label: {
                                Label("Edit comment", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    commentsStore.delete(comment.id, postID: post.id)
                                }
                            } label: {
                                Label("Delete comment", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.tertiaryText)
                                .frame(width: 24, height: 20)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Comment options")
                    }
                }

                Text(comment.text)
                    .font(.subheadline)
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .glassSurface(cornerRadius: 16, shadowed: false)

                commentLikeButton(comment)
            }

            Spacer(minLength: 0)
        }
    }

    private func commentLikeButton(_ comment: PostComment) -> some View {
        let isLiked = commentsStore.isCommentLiked(comment.id)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                commentsStore.toggleCommentLike(comment.id)
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 10, weight: .semibold))
                    .symbolEffect(.bounce, value: isLiked)

                Text("\(comment.likeCount + (isLiked ? 1 : 0))")
                    .font(.system(size: 10, weight: .semibold))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(isLiked ? Theme.rose : Theme.secondaryText)
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLiked ? "Unlike comment" : "Like comment")
    }

    // MARK: - Composer

    private var composer: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.secondaryText)
                .frame(width: 30, height: 30)
                .contentShape(Circle())
                .accessibilityLabel("Add an attachment")

            TextField("Add a comment…", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .focused($isComposerFocused)
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
            .accessibilityLabel("Send comment")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .glassSurface(cornerRadius: 26, tintOpacity: 0.6, shadowed: false)
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            commentsStore.add(text, to: post.id)
        }

        draft = ""
        isComposerFocused = false
    }
}

#Preview {
    PostDetailView(
        post: SampleFeed.posts[0],
        feedStore: FeedStore(),
        commentsStore: CommentsStore(),
        savedStore: SavedPostsStore()
    )
}
