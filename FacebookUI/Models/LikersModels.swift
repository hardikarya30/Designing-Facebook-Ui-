//
//  LikersModels.swift
//  FacebookUI
//
//  The people who liked a post, newest first.
//

import Foundation

struct Liker: Identifiable, Hashable {
    let id: String
    let name: String
    let handle: String
    let initials: String
    let palette: AvatarPalette
    let shared: String
    let isFollowing: Bool
}

enum SampleLikers {

    static let people: [Liker] = [
        Liker(id: "sophia", name: "Sophia James", handle: "@sophiajames", initials: "SJ", palette: .orchid, shared: "12 mutual friends", isFollowing: true),
        Liker(id: "james", name: "James Carter", handle: "@jamescarter", initials: "JC", palette: .azure, shared: "Designer", isFollowing: false),
        Liker(id: "emma", name: "Emma Wilson", handle: "@emmawilson", initials: "EW", palette: .amber, shared: "9 mutual friends", isFollowing: true),
        Liker(id: "maya", name: "Maya Chen", handle: "@mayachen", initials: "MC", palette: .violet, shared: "Followed by Sophia", isFollowing: false),
        Liker(id: "leo", name: "Leo Park", handle: "@leopark", initials: "LP", palette: .azure, shared: "12 mutual friends", isFollowing: false),
        Liker(id: "nadia", name: "Nadia Osman", handle: "@nadiaosman", initials: "NO", palette: .mint, shared: "Followed by James and Emma", isFollowing: true),
        Liker(id: "priya", name: "Priya Nair", handle: "@priyanair", initials: "PN", palette: .mint, shared: "6 mutual friends", isFollowing: false),
        Liker(id: "daniel", name: "Daniel Kim", handle: "@danielkim", initials: "DK", palette: .cyan, shared: "Photographer", isFollowing: true)
    ]
}
