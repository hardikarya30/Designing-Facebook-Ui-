//
//  MemoriesModels.swift
//  FacebookUI
//
//  Anniversary memories built from sample posts and posts written by the user.
//

import Foundation

struct Memory: Identifiable, Hashable {
    let id: String
    let post: Post
    let artwork: MemoryArtworkStyle
    let isFeatured: Bool

    var date: Date { post.createdAt }
    var caption: String { post.caption }

    init(post: Post, artwork: MemoryArtworkStyle, isFeatured: Bool = false) {
        self.id = "memory-\(post.id)"
        self.post = post
        self.artwork = artwork
        self.isFeatured = isFeatured
    }
}

enum MemoryArtworkStyle: Hashable {
    case city
    case coast
    case road
}

enum SampleMemories {
    static let posts: [Memory] = [
        Memory(
            post: Post(
                id: "memory-city-post",
                author: .me,
                timeAgo: "3 years ago",
                caption: "A little city wandering, a lot of good coffee.",
                symbol: "building.2.fill",
                media: .dusk,
                likeCount: 0,
                commentCount: 0,
                createdAt: anniversaryDate(year: 2023)
            ),
            artwork: .city,
            isFeatured: true
        ),
        Memory(
            post: Post(
                id: "memory-coast-post",
                author: .me,
                timeAgo: "Last year",
                caption: "A weekend worth remembering",
                symbol: "water.waves",
                media: .ocean,
                likeCount: 0,
                commentCount: 0,
                createdAt: anniversaryDate(year: 2025)
            ),
            artwork: .coast
        ),
        Memory(
            post: Post(
                id: "memory-road-post",
                author: .me,
                timeAgo: "5 years ago",
                caption: "The first summer road trip",
                symbol: "car.side.fill",
                media: .aurora,
                likeCount: 0,
                commentCount: 0,
                createdAt: anniversaryDate(year: 2021)
            ),
            artwork: .road
        )
    ]

    private static func anniversaryDate(year: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = .current
        components.year = year
        components.month = 11
        components.day = 7
        return components.date ?? .distantPast
    }
}
