//
//  SearchModels.swift
//  FacebookUI
//
//  People the search screen can find.
//

import Foundation

struct SearchPerson: Identifiable, Hashable {
    let id: String
    let name: String
    let handle: String
    let initials: String
    let palette: AvatarPalette
    let note: String
}

enum SampleSearch {

    static let people: [SearchPerson] = [
        SearchPerson(id: "alex", name: "Alex Morgan", handle: "@alexmorgan", initials: "AM", palette: .cyan, note: "12 mutual friends"),
        SearchPerson(id: "sophia", name: "Sophia James", handle: "@sophiajames", initials: "SJ", palette: .orchid, note: "Designer · 2 mutual friends"),
        SearchPerson(id: "james", name: "James Carter", handle: "@jamescarter", initials: "JC", palette: .azure, note: "Photographer"),
        SearchPerson(id: "emma", name: "Emma Wilson", handle: "@emmawilson", initials: "EW", palette: .amber, note: "9 mutual friends"),
        SearchPerson(id: "maya", name: "Maya Chen", handle: "@mayachen", initials: "MC", palette: .violet, note: "Followed by Sophia"),
        SearchPerson(id: "leo", name: "Leo Park", handle: "@leopark", initials: "LP", palette: .azure, note: "12 mutual friends"),
        SearchPerson(id: "nadia", name: "Nadia Osman", handle: "@nadiaosman", initials: "NO", palette: .mint, note: "Followed by James and Emma")
    ]

    static let recentSearches = [
        "Maya Chen",
        "northern coast",
        "#DesignSystem",
        "Alex Morgan"
    ]
}
