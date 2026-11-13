//
//  MessagesModels.swift
//  FacebookUI
//
//  A conversation as it appears in the inbox.
//

import Foundation

struct Conversation: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let preview: String
    let time: String
    var unreadCount: Int
    let isOnline: Bool
    var isPinned: Bool
}

struct SharedAddress: Hashable {
    let lines: [String]
}

enum MessageReaction: String, CaseIterable, Identifiable {
    case heart = "❤️"
    case thumbsUp = "👍"
    case laugh = "😂"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .heart: return "Love"
        case .thumbsUp: return "Like"
        case .laugh: return "Haha"
        }
    }
}

struct Message: Identifiable, Hashable {
    let id: String
    let text: String
    let isMine: Bool
    let time: String
    var post: Post? = nil
    var address: SharedAddress? = nil
    var venue: Venue? = nil
}

struct MessageRequest: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let preview: String
    let time: String
}

enum SampleMessages {

    static let conversations: [Conversation] = [
        Conversation(
            id: "alex",
            name: "Alex Morgan",
            initials: "AM",
            palette: .cyan,
            preview: "That photo from last night is unreal",
            time: "2m",
            unreadCount: 2,
            isOnline: true,
            isPinned: true
        ),
        Conversation(
            id: "sophia",
            name: "Sophia James",
            initials: "SJ",
            palette: .orchid,
            preview: "Sending the final files tonight",
            time: "18m",
            unreadCount: 0,
            isOnline: true,
            isPinned: true
        ),
        Conversation(
            id: "james",
            name: "James Carter",
            initials: "JC",
            palette: .azure,
            preview: "You: see you at the studio at 6",
            time: "1h",
            unreadCount: 0,
            isOnline: false,
            isPinned: true
        ),
        Conversation(
            id: "emma",
            name: "Emma Wilson",
            initials: "EW",
            palette: .amber,
            preview: "Haha yes, exactly that",
            time: "3h",
            unreadCount: 1,
            isOnline: true,
            isPinned: true
        ),
        Conversation(
            id: "crew",
            name: "Design Crew",
            initials: "DC",
            palette: .violet,
            preview: "Priya: new palette looks great",
            time: "Yesterday",
            unreadCount: 0,
            isOnline: false,
            isPinned: false
        ),
        Conversation(
            id: "priya",
            name: "Priya Nair",
            initials: "PN",
            palette: .mint,
            preview: "Thank you! It took a while",
            time: "Yesterday",
            unreadCount: 0,
            isOnline: false,
            isPinned: false
        )
    ]

    static let requests: [MessageRequest] = [
        MessageRequest(
            id: "priya",
            name: "Priya Nair",
            initials: "PN",
            palette: .mint,
            preview: "Hi! I saw your studio post…",
            time: "2h"
        ),
        MessageRequest(
            id: "marcus",
            name: "Marcus Reed",
            initials: "MR",
            palette: .azure,
            preview: "Are you open for freelance work?",
            time: "5h"
        )
    ]

    static let threads: [String: [Message]] = [
        "alex": [
            Message(id: "alex-1", text: "That photo from last night is unreal", isMine: false, time: "9:38 AM"),
            Message(id: "alex-2", text: "Where was that taken?", isMine: false, time: "9:38 AM"),
            Message(id: "alex-3", text: "Northern coast, just after sunset", isMine: true, time: "9:40 AM"),
            Message(id: "alex-4", text: "I'll send you the full set tonight", isMine: true, time: "9:41 AM")
        ]
    ]
}
