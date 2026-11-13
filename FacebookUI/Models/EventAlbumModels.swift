//
//  EventAlbumModels.swift
//  FacebookUI
//
//  Photos in an event's shared album.
//

import Foundation

struct EventAlbumPhoto: Identifiable, Hashable, Codable {
    let id: String
    /// SF Symbol drawn over the gradient when no library picture is used.
    let symbol: String
    let media: MediaPalette
    /// A picture from your library. When nil the tile uses the gradient artwork.
    let imageName: String?
    let isMine: Bool
}

enum SampleEventAlbum {

    /// The pictures offered when you add one from your library.
    static let libraryPhotoNames = ["FeedPhoto", "ProfileCover", "ProfileAvatar", "ProfileLogo"]

    static func photos(for event: SocialEvent) -> [EventAlbumPhoto] {
        seeds[event.id] ?? []
    }

    private static let seeds: [String: [EventAlbumPhoto]] = [
        "rooftop-jazz": album(
            eventID: "rooftop",
            symbols: ["music.note", "building.2.fill", "wineglass", "sparkles", "moon.stars.fill", "person.3.fill"],
            palettes: [.dusk, .ocean, .aurora, .dusk, .dusk, .ocean]
        ),
        "supper-club": album(
            eventID: "supper",
            symbols: ["fork.knife", "leaf.fill", "cup.and.saucer.fill", "sparkles", "wineglass", "camera.fill"],
            palettes: [.dusk, .aurora, .ocean, .dusk, .aurora, .ocean]
        ),
        "riverside-walk": album(
            eventID: "riverside",
            symbols: ["water.waves", "sun.max.fill", "figure.walk", "leaf.fill", "cloud.sun.fill", "map.fill"],
            palettes: [.ocean, .aurora, .ocean, .aurora, .ocean, .ocean]
        ),
        "film-night": album(
            eventID: "film",
            symbols: ["film.fill", "moon.stars.fill", "popcorn.fill", "sparkles", "chair.lounge.fill", "person.2.fill"],
            palettes: [.dusk, .ocean, .aurora, .dusk, .ocean, .dusk]
        ),
        "makers-market": album(
            eventID: "market",
            symbols: ["storefront.fill", "bag.fill", "cup.and.saucer.fill", "hand.raised.fill", "sparkles", "paintbrush.fill"],
            palettes: [.aurora, .ocean, .dusk, .aurora, .ocean, .aurora]
        ),
        "gallery-opening": album(
            eventID: "gallery",
            symbols: ["paintpalette.fill", "photo.artframe", "sparkles", "paintbrush.fill", "person.crop.square", "building.columns.fill"],
            palettes: [.dusk, .aurora, .dusk, .aurora, .ocean, .dusk]
        )
    ]

    private static func album(
        eventID: String,
        symbols: [String],
        palettes: [MediaPalette]
    ) -> [EventAlbumPhoto] {
        symbols.enumerated().map { index, symbol in
            EventAlbumPhoto(
                id: "\(eventID)-photo-\(index)",
                symbol: symbol,
                media: palettes[index % palettes.count],
                imageName: nil,
                isMine: false
            )
        }
    }
}
