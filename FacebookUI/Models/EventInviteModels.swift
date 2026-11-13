//
//  EventInviteModels.swift
//  FacebookUI
//
//  Friends you can invite to an event.
//

import Foundation

struct InviteFriend: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let mutualFriends: Int
}

enum SampleInviteFriends {
    static let friends: [InviteFriend] = [
        InviteFriend(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, mutualFriends: 12),
        InviteFriend(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, mutualFriends: 8),
        InviteFriend(id: "daniel", name: "Daniel Kim", initials: "DK", palette: .mint, mutualFriends: 5),
        InviteFriend(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, mutualFriends: 9),
        InviteFriend(id: "priya", name: "Priya Nair", initials: "PN", palette: .mint, mutualFriends: 4),
        InviteFriend(id: "james", name: "James Carter", initials: "JC", palette: .azure, mutualFriends: 14)
    ]
}
