//
//  FeedModels.swift
//  FacebookUI
//
//  The people, stories and posts the feed is built from.
//

import SwiftUI

struct Author: Hashable, Identifiable {
    var id: String { name }

    let name: String
    let initials: String
    let palette: AvatarPalette

    static let me = Author(name: "Hardik Arya", initials: "HA", palette: .cyan)
}

enum MediaPalette: String, CaseIterable, Hashable, Codable {
    case ocean
    case dusk
    case aurora

    var colors: [Color] {
        switch self {
        case .ocean:
            return [Color(hex: "162B54"), Color(hex: "27617F"), Color(hex: "0B1424")]
        case .dusk:
            return [Color(hex: "221A4D"), Color(hex: "4B3A9E"), Color(hex: "0D0C22")]
        case .aurora:
            return [Color(hex: "0D2E4A"), Color(hex: "177C8C"), Color(hex: "08131F")]
        }
    }

    var glow: Color {
        switch self {
        case .ocean:
            return Color(hex: "00CFFF")
        case .dusk:
            return Color(hex: "A78BFA")
        case .aurora:
            return Color(hex: "4EE1C1")
        }
    }
}

struct Post: Identifiable, Hashable {
    let id: String
    let author: Author
    let timeAgo: String
    let caption: String
    let symbol: String
    let media: MediaPalette
    let likeCount: Int
    let commentCount: Int
    let createdAt: Date
    /// Name of an image in the asset catalog. When set, the post shows that
    /// picture instead of the gradient artwork.
    let imageName: String?

    init(
        id: String = UUID().uuidString,
        author: Author,
        timeAgo: String,
        caption: String,
        symbol: String,
        media: MediaPalette,
        likeCount: Int,
        commentCount: Int,
        createdAt: Date = Date(),
        imageName: String? = nil
    ) {
        self.id = id
        self.author = author
        self.timeAgo = timeAgo
        self.caption = caption
        self.symbol = symbol
        self.media = media
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.imageName = imageName
    }
}

struct Story: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    var caption: String = ""
    var time: String = "Now"
    var symbol: String = "sparkles"
    var media: MediaPalette = .ocean
    var isMine: Bool = false
    var imageName: String? = nil
}

enum SampleFeed {

    static let stories: [Story] = [
        Story(id: "you", name: "You", initials: "AM", palette: .cyan, isMine: true),
        Story(
            id: "alex",
            name: "Alex",
            initials: "AM",
            palette: .violet,
            caption: "Last light on the northern coast",
            time: "2h",
            symbol: "mountain.2.fill",
            media: .ocean
        ),
        Story(
            id: "sophia",
            name: "Sophia",
            initials: "SJ",
            palette: .orchid,
            caption: "Frosted glass and slow mornings",
            time: "4h",
            symbol: "sparkles",
            media: .dusk
        ),
        Story(
            id: "james",
            name: "James",
            initials: "JC",
            palette: .azure,
            caption: "Studio, after midnight",
            time: "6h",
            symbol: "waveform",
            media: .aurora
        ),
        Story(
            id: "emma",
            name: "Emma",
            initials: "EW",
            palette: .amber,
            caption: "City lights on the walk home",
            time: "8h",
            symbol: "building.2.fill",
            media: .ocean
        )
    ]

    static let posts: [Post] = [
        Post(
            id: "ai-robot-brain-1",
            author: .me,
            timeAgo: "Just now",
            caption: "A glimpse into the future of AI.",
            symbol: "brain",
            media: .dusk,
            likeCount: 0,
            commentCount: 0,
            imageName: "RobotBrain"
        ),
        Post(
            id: "alex-1",
            author: Author(name: "Alex Morgan", initials: "AM", palette: .cyan),
            timeAgo: "12 min ago",
            caption: "Exploring new places and finding inspiration every day",
            symbol: "mountain.2.fill",
            media: .ocean,
            likeCount: 248,
            commentCount: 42,
            imageName: "FeedPhoto"
        ),
        Post(
            id: "sophia-1",
            author: Author(name: "Sophia James", initials: "SJ", palette: .orchid),
            timeAgo: "35 min ago",
            caption: "A little moment of creativity.",
            symbol: "sparkles",
            media: .dusk,
            likeCount: 186,
            commentCount: 24
        ),
        Post(
            id: "james-1",
            author: Author(name: "James Carter", initials: "JC", palette: .azure),
            timeAgo: "1 h ago",
            caption: "Late-night studio session. The palette finally works.",
            symbol: "waveform",
            media: .aurora,
            likeCount: 132,
            commentCount: 15
        ),
        Post(
            id: "emma-1",
            author: Author(name: "Emma Wilson", initials: "EW", palette: .amber),
            timeAgo: "3 h ago",
            caption: "City lights and slow walks. Nothing else needed.",
            symbol: "building.2.fill",
            media: .ocean,
            likeCount: 97,
            commentCount: 8
        )
    ]
}
