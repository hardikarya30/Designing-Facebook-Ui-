//
//  DiscoverModels.swift
//  FacebookUI
//
//  What the Discover screen explores: trending topics, image tiles and
//  people worth following.
//

import SwiftUI

struct TrendingTopic: Identifiable, Hashable {
    let id: String
    let tag: String
    let posts: String
}

struct ExploreTile: Identifiable, Hashable {
    let id: String
    let category: String
    let caption: String
    let symbol: String
    let media: MediaPalette
    let likeCount: Int
    let commentCount: Int
    let height: CGFloat
    let author: String
    let initials: String
    let palette: AvatarPalette
    let timeAgo: String
}

struct DiscoverPerson: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let reason: String
}

enum SampleDiscover {

    static let topics: [TrendingTopic] = [
        TrendingTopic(id: "designsystem", tag: "DesignSystem", posts: "12.4k"),
        TrendingTopic(id: "nightphotography", tag: "NightPhotography", posts: "8.1k"),
        TrendingTopic(id: "liquidglass", tag: "LiquidGlass", posts: "6.7k"),
        TrendingTopic(id: "midnightmood", tag: "MidnightMood", posts: "3.2k"),
        TrendingTopic(id: "studiolife", tag: "StudioLife", posts: "2.8k")
    ]

    static let tiles: [ExploreTile] = [
        ExploreTile(
            id: "coast",
            category: "Travel",
            caption: "Last light on the northern coast",
            symbol: "mountain.2.fill",
            media: .ocean,
            likeCount: 1240,
            commentCount: 86,
            height: 214,
            author: "Alex Morgan",
            initials: "AM",
            palette: .cyan,
            timeAgo: "2h ago"
        ),
        ExploreTile(
            id: "studio",
            category: "Photography",
            caption: "Slow frames from the studio window",
            symbol: "camera.fill",
            media: .dusk,
            likeCount: 864,
            commentCount: 41,
            height: 248,
            author: "Sophia James",
            initials: "SJ",
            palette: .orchid,
            timeAgo: "5h ago"
        ),
        ExploreTile(
            id: "sound",
            category: "Sound",
            caption: "A palette built from warm noise",
            symbol: "waveform",
            media: .aurora,
            likeCount: 512,
            commentCount: 27,
            height: 186,
            author: "James Carter",
            initials: "JC",
            palette: .azure,
            timeAgo: "Yesterday"
        ),
        ExploreTile(
            id: "city",
            category: "Urban",
            caption: "City geometry after the rain",
            symbol: "building.2.fill",
            media: .ocean,
            likeCount: 738,
            commentCount: 33,
            height: 232,
            author: "Emma Wilson",
            initials: "EW",
            palette: .amber,
            timeAgo: "1d ago"
        ),
        ExploreTile(
            id: "layers",
            category: "Design",
            caption: "Frosted layers, six experiments",
            symbol: "square.stack.3d.up.fill",
            media: .dusk,
            likeCount: 1420,
            commentCount: 118,
            height: 200,
            author: "Maya Chen",
            initials: "MC",
            palette: .violet,
            timeAgo: "1d ago"
        ),
        ExploreTile(
            id: "moon",
            category: "Night",
            caption: "Moonlight, and nothing else",
            symbol: "moon.stars.fill",
            media: .aurora,
            likeCount: 421,
            commentCount: 19,
            height: 226,
            author: "Daniel Kim",
            initials: "DK",
            palette: .mint,
            timeAgo: "2d ago"
        )
    ]

    static let people: [DiscoverPerson] = [
        DiscoverPerson(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, reason: "Followed by Sophia"),
        DiscoverPerson(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, reason: "12 mutual friends"),
        DiscoverPerson(id: "nadia", name: "Nadia Osman", initials: "NO", palette: .mint, reason: "Followed by James and Emma"),
        DiscoverPerson(id: "aria", name: "Aria Bell", initials: "AB", palette: .orchid, reason: "New to social.")
    ]
}
