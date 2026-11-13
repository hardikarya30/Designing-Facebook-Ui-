//
//  DiscoveryTopics.swift
//  FacebookUI
//
//  The web languages shown on the Discovery screen.
//

import SwiftUI

struct DiscoveryTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let glyph: String
    let colors: [Color]
    let body: String
}

enum SampleDiscovery {

    static let topics: [DiscoveryTopic] = [
        DiscoveryTopic(
            id: "html",
            title: "HTML",
            glyph: "< >",
            colors: [Color(hex: "E44D26"), Color(hex: "F16529")],
            body: "This is HTML development code for websites."
        ),
        DiscoveryTopic(
            id: "css",
            title: "CSS",
            glyph: "{ }",
            colors: [Color(hex: "264DE4"), Color(hex: "2965F1")],
            body: "This is CSS code for designing websites and for all the elements style like button and padding style and layout, for all styles."
        ),
        DiscoveryTopic(
            id: "tailwind",
            title: "Tailwind CSS",
            glyph: "~",
            colors: [Color(hex: "0EA5E9"), Color(hex: "38BDF8")],
            body: "tailwind css is a framework code for web development."
        ),
        DiscoveryTopic(
            id: "js",
            title: "JavaScript",
            glyph: "JS",
            colors: [Color(hex: "E8C300"), Color(hex: "F7DF1E")],
            body: "This is Js code for a web development and make all elements Live."
        )
    ]
}
