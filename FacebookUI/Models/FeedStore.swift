//
//  FeedStore.swift
//  FacebookUI
//
//  Keeps the feed's state: which posts are liked, the composer draft
//  and the posts written from the composer. Likes and the draft are
//  written to disk so they survive a relaunch.
//

import Combine
import Foundation

final class FeedStore: ObservableObject {

    @Published var likedPostIDs: Set<String> {
        didSet { persistLikes() }
    }

    @Published var draftText: String {
        didSet { defaults.set(draftText, forKey: Keys.draft) }
    }

    @Published private(set) var publishedPosts: [Post] = []

    private let defaults: UserDefaults

    private enum Keys {
        static let likes = "feed.likedPostIDs"
        static let draft = "feed.draftText"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.likedPostIDs = Set(defaults.stringArray(forKey: Keys.likes) ?? [])
        self.draftText = defaults.string(forKey: Keys.draft) ?? ""
    }

    var posts: [Post] {
        publishedPosts + SampleFeed.posts
    }

    func isLiked(_ postID: String) -> Bool {
        likedPostIDs.contains(postID)
    }

    func isMine(_ post: Post) -> Bool {
        post.author == .me
    }

    func updateCaption(_ caption: String, for postID: String) {
        guard let index = publishedPosts.firstIndex(where: { $0.id == postID }) else { return }

        let old = publishedPosts[index]
        publishedPosts[index] = Post(
            id: old.id,
            author: old.author,
            timeAgo: old.timeAgo,
            caption: caption,
            symbol: old.symbol,
            media: old.media,
            likeCount: old.likeCount,
            commentCount: old.commentCount,
            createdAt: old.createdAt,
            imageName: old.imageName
        )
    }

    func delete(_ postID: String) {
        publishedPosts.removeAll { $0.id == postID }
        likedPostIDs.remove(postID)
    }

    func toggleLike(_ postID: String) {
        if likedPostIDs.contains(postID) {
            likedPostIDs.remove(postID)
        } else {
            likedPostIDs.insert(postID)
        }
    }

    func publishDraft() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let post = Post(
            author: .me,
            timeAgo: "Just now",
            caption: trimmed,
            symbol: "sparkles",
            media: .dusk,
            likeCount: 0,
            commentCount: 0
        )

        publishedPosts.insert(post, at: 0)
        draftText = ""
    }

    func publishPhoto(caption: String, imageName: String) {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)

        let post = Post(
            author: .me,
            timeAgo: "Just now",
            caption: trimmed,
            symbol: "photo",
            media: .ocean,
            likeCount: 0,
            commentCount: 0,
            imageName: imageName
        )

        publishedPosts.insert(post, at: 0)
    }

    private func persistLikes() {
        defaults.set(Array(likedPostIDs), forKey: Keys.likes)
    }
}
