//
//  GroupsModels.swift
//  FacebookUI
//
//  The groups available in the hub and their membership details.
//

import SwiftUI

struct SocialGroup: Identifiable, Hashable {
    let id: String
    let name: String
    let memberCount: String
    let privacy: GroupPrivacy
    let artwork: GroupArtworkStyle
    let tintHex: String

    var tint: Color { Color(hex: tintHex) }
}

enum GroupPrivacy: String, CaseIterable, Identifiable {
    case publicGroup
    case privateGroup

    var id: String { rawValue }

    var title: String {
        switch self {
        case .publicGroup: return "Public"
        case .privateGroup: return "Private"
        }
    }

    var symbol: String {
        switch self {
        case .publicGroup: return "globe"
        case .privateGroup: return "lock.fill"
        }
    }
}

enum GroupArtworkStyle: Hashable {
    case design
    case hiking
    case photography
}

enum SampleGroups {
    static let all: [SocialGroup] = [
        SocialGroup(
            id: "design-circle",
            name: "Design Circle",
            memberCount: "12.4K",
            privacy: .publicGroup,
            artwork: .design,
            tintHex: "9B63FF"
        ),
        SocialGroup(
            id: "weekend-hikers",
            name: "Weekend Hikers",
            memberCount: "8.2K",
            privacy: .privateGroup,
            artwork: .hiking,
            tintHex: "00BDF2"
        ),
        SocialGroup(
            id: "film-photo-club",
            name: "Film & Photo Club",
            memberCount: "5.1K",
            privacy: .publicGroup,
            artwork: .photography,
            tintHex: "EE47B2"
        )
    ]
}
