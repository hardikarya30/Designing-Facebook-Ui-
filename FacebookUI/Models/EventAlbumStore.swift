//
//  EventAlbumStore.swift
//  FacebookUI
//
//  Keeps the photos you add to each event's album on this device.
//

import Combine
import Foundation

final class EventAlbumStore: ObservableObject {

    @Published private(set) var additions: [String: [EventAlbumPhoto]]

    private let defaults: UserDefaults
    private let storageKey = "events.albumPhotos"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "events.albumPhotos"),
           let saved = try? JSONDecoder().decode([String: [EventAlbumPhoto]].self, from: data) {
            additions = saved
        } else {
            additions = [:]
        }
    }

    /// The event's album, with the photos you added first.
    func photos(for event: SocialEvent) -> [EventAlbumPhoto] {
        (additions[event.id] ?? []).reversed() + SampleEventAlbum.photos(for: event)
    }

    func photos(for event: SocialEvent, mineOnly: Bool) -> [EventAlbumPhoto] {
        let all = photos(for: event)
        return mineOnly ? all.filter(\.isMine) : all
    }

    @discardableResult
    func addPhoto(to event: SocialEvent) -> EventAlbumPhoto? {
        let mineCount = (additions[event.id] ?? []).count
        guard !SampleEventAlbum.libraryPhotoNames.isEmpty else { return nil }

        let imageName = SampleEventAlbum.libraryPhotoNames[mineCount % SampleEventAlbum.libraryPhotoNames.count]
        let photo = EventAlbumPhoto(
            id: UUID().uuidString,
            symbol: "photo.fill",
            media: .aurora,
            imageName: imageName,
            isMine: true
        )

        additions[event.id, default: []].append(photo)

        if let data = try? JSONEncoder().encode(additions) {
            defaults.set(data, forKey: storageKey)
        }
        return photo
    }
}
