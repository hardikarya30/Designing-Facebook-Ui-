//
//  VenueModels.swift
//  FacebookUI
//
//  The places behind the events, kept as venues you can save and return to.
//

import CoreLocation
import Foundation

struct Venue: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let area: String
    let address: String
    let symbol: String
    let colors: [String]
    /// Text that appears in an event's location when it happens at this venue.
    let matchTerms: [String]
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum SampleVenues {
    static let all: [Venue] = [
        Venue(
            id: "skyline-terrace",
            name: "Skyline Terrace",
            area: "Shoreditch · London",
            address: "Skyline Terrace, 129 Brick Lane, London",
            symbol: "music.note",
            colors: ["263B78", "6B3B82"],
            matchTerms: ["Skyline Terrace"],
            latitude: 51.5225,
            longitude: -0.0715
        ),
        Venue(
            id: "marlow-kitchen",
            name: "Marlow Kitchen",
            area: "Hackney · London",
            address: "Marlow Kitchen, 18 Mare Street, London",
            symbol: "fork.knife",
            colors: ["75413A", "C27B48"],
            matchTerms: ["Marlow Kitchen"],
            latitude: 51.5450,
            longitude: -0.0550
        ),
        Venue(
            id: "truman-gallery",
            name: "The Truman Gallery",
            area: "E1 · London",
            address: "The Truman Gallery, 91 Brick Lane, London",
            symbol: "paintpalette.fill",
            colors: ["4B3D79", "9462A0"],
            matchTerms: ["Truman Gallery"],
            latitude: 51.5210,
            longitude: -0.0715
        ),
        Venue(
            id: "coal-drops-yard",
            name: "Coal Drops Yard",
            area: "King's Cross · London",
            address: "Coal Drops Yard, Stable Street, London",
            symbol: "storefront.fill",
            colors: ["8A5737", "C38B54"],
            matchTerms: ["Coal Drops Yard"],
            latitude: 51.5355,
            longitude: -0.1265
        ),
        Venue(
            id: "nonsuch-park",
            name: "Nonsuch Park",
            area: "Cheam · Surrey",
            address: "Nonsuch Park, Ewell Road, Cheam",
            symbol: "figure.yoga",
            colors: ["1D665B", "4F8C78"],
            matchTerms: ["Nonsuch Park"],
            latitude: 51.3620,
            longitude: -0.2330
        ),
        Venue(
            id: "cheam-village",
            name: "Cheam Village",
            area: "The Broadway · Cheam",
            address: "The Broadway, Cheam",
            symbol: "storefront",
            colors: ["8A5737", "C38B54"],
            matchTerms: ["The Broadway"],
            latitude: 51.3585,
            longitude: -0.2160
        ),
        Venue(
            id: "sutton-high-street",
            name: "Sutton High Street",
            area: "Sutton · London",
            address: "142 High Street, Sutton",
            symbol: "fork.knife",
            colors: ["75413A", "C27B48"],
            matchTerms: ["Sutton High Street"],
            latitude: 51.3615,
            longitude: -0.1945
        ),
        Venue(
            id: "wimbledon-common",
            name: "Wimbledon Common",
            area: "Wimbledon · London",
            address: "Windmill Road, Wimbledon",
            symbol: "figure.walk",
            colors: ["1D665B", "4F8C78"],
            matchTerms: ["Wimbledon Common"],
            latitude: 51.4350,
            longitude: -0.2350
        )
    ]

    /// The venues that are saved the first time the screen is opened.
    static let defaultSavedIDs = [
        "skyline-terrace",
        "marlow-kitchen",
        "truman-gallery",
        "coal-drops-yard"
    ]

    static func venue(with id: String) -> Venue? {
        all.first { $0.id == id }
    }

    static func distanceMiles(
        to venue: Venue,
        from home: CLLocationCoordinate2D = EventLocations.homeCoordinate
    ) -> Double {
        let homeLocation = CLLocation(latitude: home.latitude, longitude: home.longitude)
        let place = CLLocation(latitude: venue.latitude, longitude: venue.longitude)
        return homeLocation.distance(from: place) / 1609.344
    }
}
