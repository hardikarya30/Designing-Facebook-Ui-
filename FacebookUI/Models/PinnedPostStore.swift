//
//  PinnedPostStore.swift
//  FacebookUI
//
//  The single post pinned to the top of your profile.
//

import Combine
import Foundation

final class PinnedPostStore: ObservableObject {

    @Published private(set) var pinnedPost: Post?

    func isPinned(_ postID: String) -> Bool {
        pinnedPost?.id == postID
    }

    func toggle(_ post: Post) {
        if pinnedPost?.id == post.id {
            pinnedPost = nil
        } else {
            pinnedPost = post
        }
    }
}
