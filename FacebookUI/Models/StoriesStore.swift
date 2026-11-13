//
//  StoriesStore.swift
//  FacebookUI
//
//  Your own stories, published from the composer and shown first in the viewer.
//

import Combine
import Foundation

final class StoriesStore: ObservableObject {

    @Published private(set) var myStories: [Story] = []

    var hasStory: Bool {
        !myStories.isEmpty
    }

    /// Your story first, then everyone else's.
    var viewerStories: [Story] {
        myStories + SampleFeed.stories.filter { !$0.isMine }
    }

    func publish(caption: String, palette: MediaPalette, imageName: String?) {
        let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)

        let story = Story(
            id: "mine-\(UUID().uuidString)",
            name: "Hardik Arya",
            initials: "HA",
            palette: .cyan,
            caption: trimmed,
            time: "Now",
            symbol: "sparkles",
            media: palette,
            isMine: true,
            imageName: imageName
        )

        myStories = Array(([story] + myStories).prefix(5))
    }
}
