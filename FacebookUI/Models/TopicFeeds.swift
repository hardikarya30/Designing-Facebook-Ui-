//
//  TopicFeeds.swift
//  FacebookUI
//
//  Which feed posts carry which trending topic.
//

import Foundation

enum SampleTopicPosts {

    private static let idsByTag: [String: [String]] = [
        "DesignSystem": ["sophia-1", "alex-1"],
        "NightPhotography": ["alex-1", "emma-1"],
        "LiquidGlass": ["sophia-1"],
        "MidnightMood": ["james-1"],
        "StudioLife": []
    ]

    static func posts(for tag: String, from posts: [Post]) -> [Post] {
        let ids = idsByTag[tag] ?? []
        return ids.compactMap { id in posts.first { $0.id == id } }
    }
}
