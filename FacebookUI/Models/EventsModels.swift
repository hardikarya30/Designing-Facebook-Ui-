//
//  EventsModels.swift
//  FacebookUI
//
//  Local sample events and RSVP states for the Events hub.
//

import Foundation
import SwiftUI

enum EventRSVP: String, CaseIterable, Identifiable {
    case going
    case interested

    var id: String { rawValue }

    var title: String {
        switch self {
        case .going: return "Going"
        case .interested: return "Interested"
        }
    }

    var symbol: String {
        switch self {
        case .going: return "checkmark"
        case .interested: return "star"
        }
    }
}

enum EventCategory: String, CaseIterable, Identifiable {
    case music
    case food
    case outdoors
    case arts
    case markets

    var id: String { rawValue }

    var title: String {
        switch self {
        case .music: return "Music"
        case .food: return "Food"
        case .outdoors: return "Outdoors"
        case .arts: return "Arts"
        case .markets: return "Markets"
        }
    }

    var symbol: String {
        switch self {
        case .music: return "music.note"
        case .food: return "fork.knife"
        case .outdoors: return "figure.hiking"
        case .arts: return "paintpalette.fill"
        case .markets: return "storefront.fill"
        }
    }
}

enum EventArtworkStyle: String, Codable {
    case rooftopJazz
    case supperClub
    case riversideWalk
    case filmNight
    case makersMarket
    case galleryOpening

    var symbol: String {
        switch self {
        case .rooftopJazz: return "music.note"
        case .supperClub: return "fork.knife"
        case .riversideWalk: return "figure.hiking"
        case .filmNight: return "film"
        case .makersMarket: return "storefront.fill"
        case .galleryOpening: return "paintpalette.fill"
        }
    }

    var colors: [Color] {
        switch self {
        case .rooftopJazz: return [Color(hex: "263B78"), Color(hex: "6B3B82")]
        case .supperClub: return [Color(hex: "75413A"), Color(hex: "C27B48")]
        case .riversideWalk: return [Color(hex: "1D665B"), Color(hex: "4F8C78")]
        case .filmNight: return [Color(hex: "25304E"), Color(hex: "526A91")]
        case .makersMarket: return [Color(hex: "8A5737"), Color(hex: "C38B54")]
        case .galleryOpening: return [Color(hex: "4B3D79"), Color(hex: "9462A0")]
        }
    }
}

struct EventAttendee: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
    let shared: String
    let isInterested: Bool
}

struct EventHighlight: Identifiable, Hashable, Codable {
    let title: String
    let symbol: String

    var id: String { title }
}

struct SocialEvent: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let date: Date
    let endDate: Date
    let location: String
    let address: String
    let hostName: String
    let hostInitials: String
    let hostPalette: AvatarPalette
    let attendeeCount: Int
    let attendees: [EventAttendee]
    let extraAttendees: Int
    let description: String
    let highlights: [EventHighlight]
    let artwork: EventArtworkStyle
    let isInvitation: Bool
    let inviter: String?
}

extension SocialEvent {
    /// The category used by the Events filter, taken from the event's artwork.
    var category: EventCategory {
        switch artwork {
        case .rooftopJazz: return .music
        case .supperClub: return .food
        case .riversideWalk: return .outdoors
        case .filmNight: return .arts
        case .makersMarket: return .markets
        case .galleryOpening: return .arts
        }
    }
}

enum SampleEvents {
    static let events: [SocialEvent] = [
        SocialEvent(
            id: "rooftop-jazz",
            title: "Rooftop jazz sessions",
            date: date(daysFromNow: 2, hour: 19),
            endDate: date(daysFromNow: 2, hour: 23),
            location: "Skyline Terrace · Shoreditch",
            address: "129 Brick Lane, London",
            hostName: "Maya Chen",
            hostInitials: "MC",
            hostPalette: .violet,
            attendeeCount: 128,
            attendees: [
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: true),
                EventAttendee(id: "daniel", name: "Daniel Kim", initials: "DK", palette: .mint, shared: "Follows Night Photography · 8 mutual friends", isInterested: false),
                EventAttendee(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, shared: "Going with James · 5 mutual friends", isInterested: false)
            ],
            extraAttendees: 125,
            description: "Live jazz, city views and good company. Join us for an evening of incredible music, curated drinks and a breathtaking sunset on the Skyline Terrace.",
            highlights: [
                EventHighlight(title: "Live music", symbol: "music.note"),
                EventHighlight(title: "Curated drinks", symbol: "martini.glass"),
                EventHighlight(title: "Great company", symbol: "person.badge.plus")
            ],
            artwork: .rooftopJazz,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "supper-club",
            title: "The Sunday supper club",
            date: date(daysFromNow: 4, hour: 18),
            endDate: date(daysFromNow: 4, hour: 21),
            location: "Marlow Kitchen · Hackney",
            address: "18 Mare Street, London",
            hostName: "Kira Williams",
            hostInitials: "KW",
            hostPalette: .amber,
            attendeeCount: 36,
            attendees: [
                EventAttendee(id: "priya", name: "Priya Nair", initials: "PN", palette: .mint, shared: "Follows Food & Drink · 3 mutual friends", isInterested: true),
                EventAttendee(id: "marcus", name: "Marcus Reed", initials: "MR", palette: .azure, shared: "Interested in Marketplace · 2 mutual friends", isInterested: true),
                EventAttendee(id: "sophia", name: "Sophia James", initials: "SJ", palette: .orchid, shared: "Designer · 6 mutual friends", isInterested: false)
            ],
            extraAttendees: 33,
            description: "A relaxed Sunday table with a seasonal menu, warm conversation and a few new faces. Come hungry and leave with new friends.",
            highlights: [
                EventHighlight(title: "Seasonal menu", symbol: "leaf"),
                EventHighlight(title: "Shared table", symbol: "fork.knife"),
                EventHighlight(title: "New friends", symbol: "person.2")
            ],
            artwork: .supperClub,
            isInvitation: true,
            inviter: "Priya Shah"
        ),
        SocialEvent(
            id: "riverside-walk",
            title: "A slow walk by the river",
            date: date(daysFromNow: 6, hour: 10),
            endDate: date(daysFromNow: 6, hour: 12),
            location: "Tower Bridge, London",
            address: "Tower Bridge Road, London",
            hostName: "Daniel Kim",
            hostInitials: "DK",
            hostPalette: .mint,
            attendeeCount: 54,
            attendees: [
                EventAttendee(id: "james", name: "James Carter", initials: "JC", palette: .azure, shared: "Photographer · 14 mutual friends", isInterested: false),
                EventAttendee(id: "sophia", name: "Sophia James", initials: "SJ", palette: .orchid, shared: "Follows Arts · 6 mutual friends", isInterested: true),
                EventAttendee(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, shared: "Follows StudioLife · 9 mutual friends", isInterested: false)
            ],
            extraAttendees: 51,
            description: "Take the scenic route along the Thames, pause for coffee and enjoy a little fresh air with friendly company.",
            highlights: [
                EventHighlight(title: "Easy pace", symbol: "figure.walk"),
                EventHighlight(title: "Coffee stop", symbol: "cup.and.saucer"),
                EventHighlight(title: "River views", symbol: "water.waves")
            ],
            artwork: .riversideWalk,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "film-night",
            title: "Open-air film night",
            date: date(daysFromNow: 8, hour: 20),
            endDate: date(daysFromNow: 8, hour: 23),
            location: "Granary Square · King's Cross",
            address: "1 Stable Street, London",
            hostName: "Priya Nair",
            hostInitials: "PN",
            hostPalette: .mint,
            attendeeCount: 213,
            attendees: [
                EventAttendee(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, shared: "Follows Open-air cinema · 5 mutual friends", isInterested: true),
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: false),
                EventAttendee(id: "lena", name: "Lena Fischer", initials: "LF", palette: .orchid, shared: "Follows Arts · 4 mutual friends", isInterested: true)
            ],
            extraAttendees: 210,
            description: "Bring a blanket, pick up a snack and settle in for a favourite film under the open sky at Granary Square.",
            highlights: [
                EventHighlight(title: "Outdoor cinema", symbol: "film"),
                EventHighlight(title: "Street food", symbol: "takeoutbag.and.cup.and.straw"),
                EventHighlight(title: "Bring a blanket", symbol: "sparkles")
            ],
            artwork: .filmNight,
            isInvitation: true,
            inviter: "Daniel Kim"
        ),
        SocialEvent(
            id: "makers-market",
            title: "Sunday makers market",
            date: date(daysFromNow: 11, hour: 11),
            endDate: date(daysFromNow: 11, hour: 16),
            location: "Coal Drops Yard, London",
            address: "Stable Street, King's Cross",
            hostName: "Emma Wilson",
            hostInitials: "EW",
            hostPalette: .amber,
            attendeeCount: 87,
            attendees: [
                EventAttendee(id: "james", name: "James Carter", initials: "JC", palette: .azure, shared: "Photographer · 14 mutual friends", isInterested: true),
                EventAttendee(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, shared: "Follows StudioLife · 9 mutual friends", isInterested: false),
                EventAttendee(id: "marcus", name: "Marcus Reed", initials: "MR", palette: .azure, shared: "Interested in Marketplace · 2 mutual friends", isInterested: false)
            ],
            extraAttendees: 84,
            description: "Spend the afternoon discovering independent makers, thoughtful gifts and excellent coffee in the heart of King's Cross.",
            highlights: [
                EventHighlight(title: "Local makers", symbol: "hand.raised"),
                EventHighlight(title: "Good coffee", symbol: "cup.and.saucer"),
                EventHighlight(title: "Browse & enjoy", symbol: "sparkles")
            ],
            artwork: .makersMarket,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "gallery-opening",
            title: "New voices: gallery opening",
            date: date(daysFromNow: 13, hour: 18),
            endDate: date(daysFromNow: 13, hour: 21),
            location: "The Truman Gallery · E1",
            address: "91 Brick Lane, London",
            hostName: "Sophia James",
            hostInitials: "SJ",
            hostPalette: .orchid,
            attendeeCount: 69,
            attendees: [
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: false),
                EventAttendee(id: "daniel", name: "Daniel Kim", initials: "DK", palette: .mint, shared: "Follows Night Photography · 8 mutual friends", isInterested: true),
                EventAttendee(id: "priya", name: "Priya Nair", initials: "PN", palette: .mint, shared: "Follows Food & Drink · 3 mutual friends", isInterested: false)
            ],
            extraAttendees: 66,
            description: "Meet the artists behind a new collection celebrating bold ideas, bright colour and the next generation of London creatives.",
            highlights: [
                EventHighlight(title: "New artists", symbol: "person.crop.square"),
                EventHighlight(title: "Opening night", symbol: "sparkles"),
                EventHighlight(title: "East London", symbol: "mappin.and.ellipse")
            ],
            artwork: .galleryOpening,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "near-sunset-yoga",
            title: "Sunset yoga in the park",
            date: date(daysFromNow: 1, hour: 18),
            endDate: date(daysFromNow: 1, hour: 20),
            location: "Nonsuch Park · Cheam",
            address: "Nonsuch Park, Ewell Road, Cheam",
            hostName: "Aisha Khan",
            hostInitials: "AK",
            hostPalette: .violet,
            attendeeCount: 24,
            attendees: [
                EventAttendee(id: "priya", name: "Priya Nair", initials: "PN", palette: .mint, shared: "Follows Outdoors · 3 mutual friends", isInterested: true),
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: false),
                EventAttendee(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, shared: "Going with James · 5 mutual friends", isInterested: true)
            ],
            extraAttendees: 21,
            description: "A slow, guided flow on the grass as the sun goes down, followed by tea and a few quiet minutes. Mats and blankets are provided.",
            highlights: [
                EventHighlight(title: "Guided flow", symbol: "figure.yoga"),
                EventHighlight(title: "Tea afterwards", symbol: "cup.and.saucer"),
                EventHighlight(title: "Open air", symbol: "sun.max")
            ],
            artwork: .riversideWalk,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "cheam-night-market",
            title: "Cheam village night market",
            date: date(daysFromNow: 3, hour: 17),
            endDate: date(daysFromNow: 3, hour: 21),
            location: "The Broadway · Cheam",
            address: "1 The Broadway, Cheam",
            hostName: "Tom Fletcher",
            hostInitials: "TF",
            hostPalette: .amber,
            attendeeCount: 62,
            attendees: [
                EventAttendee(id: "james", name: "James Carter", initials: "JC", palette: .azure, shared: "Photographer · 14 mutual friends", isInterested: true),
                EventAttendee(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, shared: "Follows StudioLife · 9 mutual friends", isInterested: true),
                EventAttendee(id: "marcus", name: "Marcus Reed", initials: "MR", palette: .azure, shared: "Interested in Marketplace · 2 mutual friends", isInterested: false)
            ],
            extraAttendees: 59,
            description: "Stalls from local makers, hot food and a small stage of live music, right in the middle of Cheam village.",
            highlights: [
                EventHighlight(title: "Local stalls", symbol: "storefront"),
                EventHighlight(title: "Street food", symbol: "takeoutbag.and.cup.and.straw"),
                EventHighlight(title: "Live music", symbol: "music.mic")
            ],
            artwork: .makersMarket,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "sutton-brunch-club",
            title: "Sunday brunch club",
            date: date(daysFromNow: 5, hour: 11),
            endDate: date(daysFromNow: 5, hour: 13),
            location: "Sutton High Street",
            address: "142 High Street, Sutton",
            hostName: "Rosa Martin",
            hostInitials: "RM",
            hostPalette: .orchid,
            attendeeCount: 18,
            attendees: [
                EventAttendee(id: "sophia", name: "Sophia James", initials: "SJ", palette: .orchid, shared: "Designer · 6 mutual friends", isInterested: true),
                EventAttendee(id: "priya", name: "Priya Nair", initials: "PN", palette: .mint, shared: "Follows Food & Drink · 3 mutual friends", isInterested: false),
                EventAttendee(id: "lena", name: "Lena Fischer", initials: "LF", palette: .orchid, shared: "Follows Arts · 4 mutual friends", isInterested: true)
            ],
            extraAttendees: 15,
            description: "A long table, a short menu and a good excuse to meet people from the area. Coffee keeps coming until the plates are cleared.",
            highlights: [
                EventHighlight(title: "Long table", symbol: "fork.knife"),
                EventHighlight(title: "Bottomless coffee", symbol: "cup.and.saucer"),
                EventHighlight(title: "Local crowd", symbol: "person.2")
            ],
            artwork: .supperClub,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "wimbledon-common-walk",
            title: "Wimbledon common walk",
            date: date(daysFromNow: 9, hour: 10),
            endDate: date(daysFromNow: 9, hour: 12),
            location: "Wimbledon Common",
            address: "Windmill Road, Wimbledon",
            hostName: "Daniel Kim",
            hostInitials: "DK",
            hostPalette: .mint,
            attendeeCount: 41,
            attendees: [
                EventAttendee(id: "daniel", name: "Daniel Kim", initials: "DK", palette: .mint, shared: "Follows Night Photography · 8 mutual friends", isInterested: false),
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: true),
                EventAttendee(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, shared: "Going with James · 5 mutual friends", isInterested: false)
            ],
            extraAttendees: 38,
            description: "Two hours on the common with a coffee stop halfway. Easy paths, friendly pace, dogs very welcome.",
            highlights: [
                EventHighlight(title: "Easy paths", symbol: "figure.walk"),
                EventHighlight(title: "Coffee stop", symbol: "cup.and.saucer"),
                EventHighlight(title: "Wide open space", symbol: "tree")
            ],
            artwork: .riversideWalk,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "past-rooftop-jazz",
            title: "Late-night jazz on the roof",
            date: date(daysFromNow: -14, hour: 19),
            endDate: date(daysFromNow: -14, hour: 23),
            location: "Skyline Terrace · Shoreditch",
            address: "129 Brick Lane, London",
            hostName: "Maya Chen",
            hostInitials: "MC",
            hostPalette: .violet,
            attendeeCount: 128,
            attendees: [
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: false),
                EventAttendee(id: "daniel", name: "Daniel Kim", initials: "DK", palette: .mint, shared: "Follows Night Photography · 8 mutual friends", isInterested: false),
                EventAttendee(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, shared: "Going with James · 5 mutual friends", isInterested: false)
            ],
            extraAttendees: 125,
            description: "Live jazz, city views and good company under the open sky. A night of incredible music and a breathtaking sunset on the Skyline Terrace.",
            highlights: [
                EventHighlight(title: "Live music", symbol: "music.note"),
                EventHighlight(title: "Rooftop views", symbol: "building.2"),
                EventHighlight(title: "Great company", symbol: "person.badge.plus")
            ],
            artwork: .rooftopJazz,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "past-makers-market",
            title: "Winter makers market",
            date: date(daysFromNow: -45, hour: 11),
            endDate: date(daysFromNow: -45, hour: 16),
            location: "Coal Drops Yard, London",
            address: "Stable Street, King's Cross",
            hostName: "Emma Wilson",
            hostInitials: "EW",
            hostPalette: .amber,
            attendeeCount: 64,
            attendees: [
                EventAttendee(id: "james", name: "James Carter", initials: "JC", palette: .azure, shared: "Photographer · 14 mutual friends", isInterested: false),
                EventAttendee(id: "maya", name: "Maya Chen", initials: "MC", palette: .violet, shared: "Follows StudioLife · 9 mutual friends", isInterested: false),
                EventAttendee(id: "marcus", name: "Marcus Reed", initials: "MR", palette: .azure, shared: "Interested in Marketplace · 2 mutual friends", isInterested: false)
            ],
            extraAttendees: 61,
            description: "Independent makers, thoughtful gifts and excellent coffee in the heart of King's Cross.",
            highlights: [
                EventHighlight(title: "Local makers", symbol: "hand.raised"),
                EventHighlight(title: "Good coffee", symbol: "cup.and.saucer"),
                EventHighlight(title: "Winter lights", symbol: "sparkles")
            ],
            artwork: .makersMarket,
            isInvitation: false,
            inviter: nil
        ),
        SocialEvent(
            id: "past-film-night",
            title: "Film under the stars",
            date: date(daysFromNow: -210, hour: 20),
            endDate: date(daysFromNow: -210, hour: 23),
            location: "Granary Square · King's Cross",
            address: "1 Stable Street, London",
            hostName: "Priya Nair",
            hostInitials: "PN",
            hostPalette: .mint,
            attendeeCount: 96,
            attendees: [
                EventAttendee(id: "emma", name: "Emma Wilson", initials: "EW", palette: .amber, shared: "Follows Open-air cinema · 5 mutual friends", isInterested: false),
                EventAttendee(id: "leo", name: "Leo Park", initials: "LP", palette: .azure, shared: "Interested in Design System · 12 mutual friends", isInterested: false),
                EventAttendee(id: "lena", name: "Lena Fischer", initials: "LF", palette: .orchid, shared: "Follows Arts · 4 mutual friends", isInterested: false)
            ],
            extraAttendees: 93,
            description: "A blanket, a snack and a favourite film under the open sky at Granary Square.",
            highlights: [
                EventHighlight(title: "Outdoor cinema", symbol: "film"),
                EventHighlight(title: "Street food", symbol: "takeoutbag.and.cup.and.straw"),
                EventHighlight(title: "Bring a blanket", symbol: "sparkles")
            ],
            artwork: .filmNight,
            isInvitation: false,
            inviter: nil
        )
    ]

    private static func date(daysFromNow days: Int, hour: Int) -> Date {
        let calendar = Calendar.current
        let day = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: Date())) ?? Date()
        return calendar.date(byAdding: .hour, value: hour, to: day) ?? day
    }
}
