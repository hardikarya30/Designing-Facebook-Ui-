//
//  CommentsStore.swift
//  FacebookUI
//
//  Holds the comment threads and the comments written this session.
//

import Combine
import Foundation

final class CommentsStore: ObservableObject {

    @Published private(set) var threads: [String: [PostComment]] = SampleComments.byPost
    @Published private(set) var addedCounts: [String: Int] = [:]
    @Published private(set) var deletedCounts: [String: Int] = [:]
    @Published private(set) var likedCommentIDs: Set<String> = []

    func isCommentLiked(_ commentID: String) -> Bool {
        likedCommentIDs.contains(commentID)
    }

    func toggleCommentLike(_ commentID: String) {
        if likedCommentIDs.contains(commentID) {
            likedCommentIDs.remove(commentID)
        } else {
            likedCommentIDs.insert(commentID)
        }
    }

    func comments(for postID: String) -> [PostComment] {
        threads[postID] ?? SampleComments.generic
    }

    func addedCount(for postID: String) -> Int {
        addedCounts[postID] ?? 0
    }

    func deletedCount(for postID: String) -> Int {
        deletedCounts[postID] ?? 0
    }

    func update(_ text: String, commentID: String, postID: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var list = threads[postID] ?? SampleComments.generic
        guard let index = list.firstIndex(where: { $0.id == commentID }) else { return }

        list[index].text = trimmed
        threads[postID] = list
    }

    func delete(_ commentID: String, postID: String) {
        var list = threads[postID] ?? SampleComments.generic
        guard list.contains(where: { $0.id == commentID }) else { return }

        list.removeAll { $0.id == commentID }
        threads[postID] = list
        deletedCounts[postID, default: 0] += 1
    }

    func add(_ text: String, to postID: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var list = threads[postID] ?? SampleComments.generic
        list.append(
            PostComment(
                id: UUID().uuidString,
                author: .me,
                text: trimmed,
                time: "Just now",
                likeCount: 0
            )
        )

        threads[postID] = list
        addedCounts[postID, default: 0] += 1
    }
}
