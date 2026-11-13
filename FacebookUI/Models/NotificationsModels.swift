//
//  NotificationsModels.swift
//  FacebookUI
//
//  Activity on the account — likes, comments, follows and mentions.
//

import SwiftUI

enum NotificationGroup: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "This week"
    case earlier = "Earlier"

    var id: String { rawValue }

    var title: String { rawValue }
}

enum NotificationKind: String, Hashable {
    case like
    case comment
    case follow
    case mention

    var icon: String {
        switch self {
        case .like: return "heart.fill"
        case .comment: return "bubble.left.fill"
        case .follow: return "person.fill.badge.plus"
        case .mention: return "tag.fill"
        }
    }

    var tint: Color {
        switch self {
        case .like: return Theme.rose
        case .comment: return Theme.cyan
        case .follow: return Theme.violet
        case .mention: return Color(hex: "4D8BFF")
        }
    }

    var label: String {
        switch self {
        case .like: return "Like"
        case .comment: return "Comment"
        case .follow: return "Follow"
        case .mention: return "Mention"
        }
    }
}

struct ActivityNotification: Identifiable, Hashable {
    let id: String
    let actorName: String
    let initials: String
    let palette: AvatarPalette
    let kind: NotificationKind
    let message: String
    let time: String
    let group: NotificationGroup
    var isRead: Bool
}

enum SampleNotifications {

    static let items: [ActivityNotification] = [
        ActivityNotification(
            id: "alex-like",
            actorName: "Alex Morgan",
            initials: "AM",
            palette: .cyan,
            kind: .like,
            message: "liked your post",
            time: "2m",
            group: .today,
            isRead: false
        ),
        ActivityNotification(
            id: "sophia-comment",
            actorName: "Sophia James",
            initials: "SJ",
            palette: .orchid,
            kind: .comment,
            message: "commented: “This palette is stunning”",
            time: "25m",
            group: .today,
            isRead: false
        ),
        ActivityNotification(
            id: "james-follow",
            actorName: "James Carter",
            initials: "JC",
            palette: .azure,
            kind: .follow,
            message: "started following you",
            time: "1h",
            group: .today,
            isRead: false
        ),
        ActivityNotification(
            id: "emma-mention",
            actorName: "Emma Wilson",
            initials: "EW",
            palette: .amber,
            kind: .mention,
            message: "mentioned you in a comment",
            time: "3h",
            group: .today,
            isRead: true
        ),
        ActivityNotification(
            id: "priya-like",
            actorName: "Priya Nair",
            initials: "PN",
            palette: .mint,
            kind: .like,
            message: "liked your story",
            time: "Yesterday",
            group: .week,
            isRead: true
        ),
        ActivityNotification(
            id: "daniel-comment",
            actorName: "Daniel Kim",
            initials: "DK",
            palette: .mint,
            kind: .comment,
            message: "commented on your photo",
            time: "2d",
            group: .week,
            isRead: false
        ),
        ActivityNotification(
            id: "maya-follow",
            actorName: "Maya Chen",
            initials: "MC",
            palette: .violet,
            kind: .follow,
            message: "started following you",
            time: "3d",
            group: .week,
            isRead: true
        ),
        ActivityNotification(
            id: "leo-mention",
            actorName: "Leo Park",
            initials: "LP",
            palette: .azure,
            kind: .mention,
            message: "mentioned you in a post",
            time: "1w",
            group: .earlier,
            isRead: true
        ),
        ActivityNotification(
            id: "nadia-like",
            actorName: "Nadia Osman",
            initials: "NO",
            palette: .mint,
            kind: .like,
            message: "liked your comment",
            time: "1w",
            group: .earlier,
            isRead: true
        )
    ]
}
