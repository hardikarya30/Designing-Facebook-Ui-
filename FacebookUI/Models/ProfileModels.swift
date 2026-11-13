//
//  ProfileModels.swift
//  FacebookUI
//
//  The signed-in user's profile and the content shown on it.
//

import SwiftUI

struct Profile: Codable, Equatable {
    var name: String
    var handle: String
    var role: String
    var bio: String
    var work: String
    var location: String
    var joined: String
    var postsCount: Int
    var friendsCount: Int
    var followingCount: Int

    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first }.map(String.init).joined().uppercased()
    }
}

struct ProfilePhoto: Identifiable, Hashable {
    let id: String
    let symbol: String
    let media: MediaPalette
    let caption: String
}

struct ProfilePerson: Identifiable, Hashable {
    let id: String
    let name: String
    let handle: String
    let initials: String
    let palette: AvatarPalette
}

enum SampleProfile {

    static let profile = Profile(
        name: "Hardik Arya",
        handle: "@hafreelancers",
        role: "Designer, System Studio",
        bio: "Building calm interfaces in the dark. Night photography, glass and good coffee.",
        work: "",
        location: "London, UK",
        joined: "Joined November 2026",
        postsCount: 128,
        friendsCount: 2412,
        followingCount: 312
    )

    static let posts: [Post] = [
        Post(
            id: "own-1",
            author: .me,
            timeAgo: "Yesterday",
            caption: "Frosted glass, midnight blue and a little cyan.",
            symbol: "square.stack.3d.up.fill",
            media: .dusk,
            likeCount: 342,
            commentCount: 28
        ),
        Post(
            id: "own-2",
            author: .me,
            timeAgo: "3d ago",
            caption: "Chasing the last light before the city went quiet.",
            symbol: "moon.stars.fill",
            media: .ocean,
            likeCount: 219,
            commentCount: 14
        )
    ]

    static let photos: [ProfilePhoto] = [
        ProfilePhoto(id: "p1", symbol: "mountain.2.fill", media: .ocean, caption: "Last light on the northern coast"),
        ProfilePhoto(id: "p2", symbol: "camera.fill", media: .dusk, caption: "Slow frames from the studio window"),
        ProfilePhoto(id: "p3", symbol: "sparkles", media: .aurora, caption: "A little moment of creativity"),
        ProfilePhoto(id: "p4", symbol: "building.2.fill", media: .ocean, caption: "City geometry after the rain"),
        ProfilePhoto(id: "p5", symbol: "moon.stars.fill", media: .dusk, caption: "Moonlight, and nothing else"),
        ProfilePhoto(id: "p6", symbol: "waveform", media: .aurora, caption: "A palette built from warm noise")
    ]

    static let following: [ProfilePerson] = [
        ProfilePerson(id: "maya", name: "Maya Chen", handle: "@mayachen", initials: "MC", palette: .violet),
        ProfilePerson(id: "leo", name: "Leo Park", handle: "@leopark", initials: "LP", palette: .azure),
        ProfilePerson(id: "nadia", name: "Nadia Osman", handle: "@nadiaosman", initials: "NO", palette: .mint),
        ProfilePerson(id: "aria", name: "Aria Bell", handle: "@ariabell", initials: "AB", palette: .orchid)
    ]
}
