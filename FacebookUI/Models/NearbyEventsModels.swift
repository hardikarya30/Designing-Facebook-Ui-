//
//  NearbyEventsModels.swift
//  FacebookUI
//
//  Distances from your saved home address to the events you could go to.
//

import CoreLocation
import Foundation

struct NearbyEvent: Identifiable {
    let event: SocialEvent
    let distanceMiles: Double

    var id: String { event.id }

    var distanceLabel: String {
        String(format: "%.1f miles away", distanceMiles)
    }
}

enum EventLocations {
    /// The saved home address, in North Cheam.
    static let homeCoordinate = CLLocationCoordinate2D(latitude: 51.3695, longitude: -0.2260)

    /// The point each sample event happens at, so it can be shown on the map.
    static func coordinate(for event: SocialEvent) -> CLLocationCoordinate2D {
        switch event.id {
        case "rooftop-jazz", "past-rooftop-jazz":
            return CLLocationCoordinate2D(latitude: 51.5225, longitude: -0.0715)
        case "supper-club":
            return CLLocationCoordinate2D(latitude: 51.5450, longitude: -0.0550)
        case "riverside-walk":
            return CLLocationCoordinate2D(latitude: 51.5045, longitude: -0.0750)
        case "film-night", "past-film-night":
            return CLLocationCoordinate2D(latitude: 51.5350, longitude: -0.1250)
        case "makers-market", "past-makers-market":
            return CLLocationCoordinate2D(latitude: 51.5355, longitude: -0.1265)
        case "gallery-opening":
            return CLLocationCoordinate2D(latitude: 51.5210, longitude: -0.0715)
        case "near-sunset-yoga":
            return CLLocationCoordinate2D(latitude: 51.3620, longitude: -0.2330)
        case "cheam-night-market":
            return CLLocationCoordinate2D(latitude: 51.3585, longitude: -0.2160)
        case "sutton-brunch-club":
            return CLLocationCoordinate2D(latitude: 51.3615, longitude: -0.1945)
        case "wimbledon-common-walk":
            return CLLocationCoordinate2D(latitude: 51.4350, longitude: -0.2350)
        default:
            return CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        }
    }

    /// The events still to come that sit inside the radius, closest first.
    static func nearbyEvents(
        from events: [SocialEvent],
        home: CLLocationCoordinate2D = homeCoordinate,
        withinMiles limit: Double = 5
    ) -> [NearbyEvent] {
        let homeLocation = CLLocation(latitude: home.latitude, longitude: home.longitude)
        let now = Date()

        return events
            .filter { $0.endDate >= now }
            .compactMap { event -> NearbyEvent? in
                let point = coordinate(for: event)
                let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
                let miles = homeLocation.distance(from: location) / 1609.344
                guard miles <= limit else { return nil }
                return NearbyEvent(event: event, distanceMiles: miles)
            }
            .sorted { $0.distanceMiles < $1.distanceMiles }
    }

    /// How far an event is from home, in miles, however far away it is.
    static func distanceMiles(
        to event: SocialEvent,
        home: CLLocationCoordinate2D = homeCoordinate
    ) -> Double {
        let homeLocation = CLLocation(latitude: home.latitude, longitude: home.longitude)
        let point = coordinate(for: event)
        let eventLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
        return homeLocation.distance(from: eventLocation) / 1609.344
    }

    /// "0.6 mi from home" for the event cards.
    static func distanceLabel(for event: SocialEvent) -> String {
        String(format: "%.1f mi from home", distanceMiles(to: event))
    }
}
