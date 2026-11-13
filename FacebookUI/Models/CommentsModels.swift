//
//  CommentsModels.swift
//  FacebookUI
//
//  Comments on a post, and the sample threads the detail screen opens with.
//

import Foundation

struct PostComment: Identifiable, Hashable {
    let id: String
    let author: Author
    var text: String
    let time: String
    var likeCount: Int
}

enum SampleComments {

    static let byPost: [String: [PostComment]] = [
        "alex-1": [
            PostComment(
                id: "alex-1-c1",
                author: Author(name: "Sophia James", initials: "SJ", palette: .orchid),
                text: "This palette is stunning.",
                time: "2h",
                likeCount: 24
            ),
            PostComment(
                id: "alex-1-c2",
                author: Author(name: "James Carter", initials: "JC", palette: .azure),
                text: "Where was this taken?",
                time: "1h",
                likeCount: 11
            ),
            PostComment(
                id: "alex-1-c3",
                author: Author(name: "Emma Wilson", initials: "EW", palette: .amber),
                text: "That light is unreal.",
                time: "45m",
                likeCount: 8
            )
        ],
        "sophia-1": [
            PostComment(
                id: "sophia-1-c1",
                author: .me,
                text: "Saving this for the next moodboard.",
                time: "30m",
                likeCount: 9
            ),
            PostComment(
                id: "sophia-1-c2",
                author: Author(name: "Maya Chen", initials: "MC", palette: .violet),
                text: "The texture is so good.",
                time: "20m",
                likeCount: 5
            )
        ]
    ]

    static let generic: [PostComment] = [
        PostComment(
            id: "generic-c1",
            author: Author(name: "Sophia James", initials: "SJ", palette: .orchid),
            text: "This is beautiful.",
            time: "2h",
            likeCount: 6
        ),
        PostComment(
            id: "generic-c2",
            author: Author(name: "James Carter", initials: "JC", palette: .azure),
            text: "Where was this taken?",
            time: "1h",
            likeCount: 2
        ),
        PostComment(
            id: "generic-c3",
            author: Author(name: "Emma Wilson", initials: "EW", palette: .amber),
            text: "That light is unreal.",
            time: "45m",
            likeCount: 4
        )
    ]
}
