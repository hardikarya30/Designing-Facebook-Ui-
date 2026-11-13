//
//  EventDiscussionModels.swift
//  FacebookUI
//
//  Messages posted in an event's discussion thread.
//

import Foundation

struct EventDiscussionMessage: Codable, Hashable, Identifiable {
    let id: String
    let authorName: String
    let initials: String
    let palette: AvatarPalette
    let text: String
    let createdAt: Date
    let isMine: Bool

    var relativeTime: String {
        let seconds = max(0, Date().timeIntervalSince(createdAt))
        if seconds < 60 { return "Just now" }
        if seconds < 3_600 { return "\(Int(seconds / 60))m" }
        if seconds < 86_400 { return "\(Int(seconds / 3_600))h" }
        return "\(Int(seconds / 86_400))d"
    }
}

enum SampleEventDiscussion {

    static func messages(for event: SocialEvent) -> [EventDiscussionMessage] {
        threads[event.id] ?? []
    }

    private static let threads: [String: [EventDiscussionMessage]] = [
        "rooftop-jazz": [
            message(
                id: "rooftop-1",
                author: "Maya Chen",
                initials: "MC",
                palette: .violet,
                text: "Doors open at 7 — come early if you want a spot by the terrace edge.",
                hoursAgo: 26
            ),
            message(
                id: "rooftop-2",
                author: "Leo Park",
                initials: "LP",
                palette: .azure,
                text: "Bringing two friends along. Is there a dress code?",
                hoursAgo: 21
            ),
            message(
                id: "rooftop-3",
                author: "Maya Chen",
                initials: "MC",
                palette: .violet,
                text: "Nothing formal — just something you can dance in.",
                hoursAgo: 20
            )
        ],
        "supper-club": [
            message(
                id: "supper-1",
                author: "Kira Williams",
                initials: "KW",
                palette: .amber,
                text: "The menu is set. Tell me now if anyone is vegetarian.",
                hoursAgo: 30
            ),
            message(
                id: "supper-2",
                author: "Priya Nair",
                initials: "PN",
                palette: .mint,
                text: "Me please! Otherwise I eat everything.",
                hoursAgo: 27
            )
        ],
        "film-night": [
            message(
                id: "film-1",
                author: "Priya Nair",
                initials: "PN",
                palette: .mint,
                text: "Blankets are essential. It gets cold by the water after sunset.",
                hoursAgo: 12
            )
        ],
        "makers-market": [
            message(
                id: "market-1",
                author: "Emma Wilson",
                initials: "EW",
                palette: .amber,
                text: "Stall list is up — the ceramics table is worth a stop.",
                hoursAgo: 40
            )
        ]
    ]

    private static func message(
        id: String,
        author: String,
        initials: String,
        palette: AvatarPalette,
        text: String,
        hoursAgo: Double
    ) -> EventDiscussionMessage {
        EventDiscussionMessage(
            id: id,
            authorName: author,
            initials: initials,
            palette: palette,
            text: text,
            createdAt: Date().addingTimeInterval(-hoursAgo * 3_600),
            isMine: false
        )
    }
}
