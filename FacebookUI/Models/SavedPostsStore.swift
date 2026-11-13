//
//  SavedPostsStore.swift
//  FacebookUI
//
//  Posts bookmarked for later, kept on disk so they survive a relaunch.
//

import Combine
import Foundation

final class SavedPostsStore: ObservableObject {

    /// Newest saved first.
    @Published private(set) var savedIDs: [String] = []

    private let defaults: UserDefaults
    private let storageKey = "saved.postIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.savedIDs = defaults.stringArray(forKey: "saved.postIDs") ?? []
    }

    func isSaved(_ postID: String) -> Bool {
        savedIDs.contains(postID)
    }

    func toggle(_ postID: String) {
        if isSaved(postID) {
            savedIDs.removeAll { $0 == postID }
        } else {
            savedIDs.insert(postID, at: 0)
        }

        persist()
    }

    func remove(_ postID: String) {
        savedIDs.removeAll { $0 == postID }
        persist()
    }

    func savedPosts(from posts: [Post]) -> [Post] {
        savedIDs.compactMap { id in
            posts.first { $0.id == id }
        }
    }

    private func persist() {
        defaults.set(savedIDs, forKey: storageKey)
    }
}
