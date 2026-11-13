//
//  StoryViewersModels.swift
//  FacebookUI
//
//  Everyone who watched your story, newest first.
//

import Foundation

struct StoryViewerPerson: Identifiable, Hashable {
    let id: String
    let name: String
    let handle: String
    let initials: String
    let palette: AvatarPalette
    let time: String
    let reacted: Bool
}

enum SampleStoryViewers {

    static let total = 842

    static let people: [StoryViewerPerson] = [
        StoryViewerPerson(id: "alex", name: "Alex Morgan", handle: "@alexmorgan", initials: "AM", palette: .cyan, time: "2m", reacted: true),
        StoryViewerPerson(id: "sophia", name: "Sophia James", handle: "@sophiajames", initials: "SJ", palette: .orchid, time: "6m", reacted: true),
        StoryViewerPerson(id: "james", name: "James Carter", handle: "@jamescarter", initials: "JC", palette: .azure, time: "14m", reacted: false),
        StoryViewerPerson(id: "emma", name: "Emma Wilson", handle: "@emmawilson", initials: "EW", palette: .amber, time: "28m", reacted: true),
        StoryViewerPerson(id: "maya", name: "Maya Chen", handle: "@mayachen", initials: "MC", palette: .violet, time: "45m", reacted: false),
        StoryViewerPerson(id: "leo", name: "Leo Park", handle: "@leopark", initials: "LP", palette: .azure, time: "1h", reacted: false),
        StoryViewerPerson(id: "nadia", name: "Nadia Osman", handle: "@nadiaosman", initials: "NO", palette: .mint, time: "2h", reacted: true),
        StoryViewerPerson(id: "priya", name: "Priya Nair", handle: "@priyanair", initials: "PN", palette: .mint, time: "3h", reacted: false)
    ]
}
