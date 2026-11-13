//
//  FriendsModels.swift
//  FacebookUI
//
//  People on the Friends screen: the friend list, the incoming requests
//  and the suggestions to follow.
//

import SwiftUI

struct Friend: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let isOnline: Bool
    let status: String
}

struct FriendRequest: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let mutualFriends: Int
}

struct FriendSuggestion: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let reason: String
}

enum SampleFriends {

    static let friends: [Friend] = [
        Friend(id: "sophia", name: "Sophia James", initials: "SJ", palette: .orchid, isOnline: true, status: "Active now"),
        Friend(id: "james", name: "James Carter", initials: "JC", palette: .azure, isOnline: false, status: "Last seen 2h ago"),
        Friend(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, isOnline: true, status: "Active now"),
        Friend(id: "alex", name: "Alex Morgan", initials: "AM", palette: .cyan, isOnline: true, status: "Active now"),
        Friend(id: "daniel", name: "Daniel Kim", initials: "DK", palette: .mint, isOnline: false, status: "Last seen yesterday")
    ]

    static let requests: [FriendRequest] = [
        FriendRequest(id: "priya", name: "Priya Nair", initials: "PN", palette: .mint, mutualFriends: 12),
        FriendRequest(id: "marcus", name: "Marcus Reed", initials: "MR", palette: .azure, mutualFriends: 9),
        FriendRequest(id: "lena", name: "Lena Fischer", initials: "LF", palette: .orchid, mutualFriends: 6)
    ]

    static let suggestions: [FriendSuggestion] = [
        FriendSuggestion(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, reason: "Followed by Sophia"),
        FriendSuggestion(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, reason: "12 mutual friends"),
        FriendSuggestion(id: "nadia", name: "Nadia Osman", initials: "NO", palette: .mint, reason: "Followed by James and Emma")
    ]
}
