//
//  MarketplaceModels.swift
//  FacebookUI
//
//  Sample local listings and the categories shown in Marketplace.
//

import SwiftUI

enum MarketplaceCategory: String, CaseIterable, Identifiable, Hashable {
    case forYou
    case vehicles
    case home
    case electronics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .forYou: return "For you"
        case .vehicles: return "Vehicles"
        case .home: return "Home"
        case .electronics: return "Electronics"
        }
    }

    var symbol: String {
        switch self {
        case .forYou: return "bag"
        case .vehicles: return "car.side"
        case .home: return "house"
        case .electronics: return "laptopcomputer"
        }
    }
}

enum ListingArtworkStyle: Hashable {
    case vintageCamera
    case armchair
    case roadBike
    case deskLamp
}

struct MarketplaceListing: Identifiable, Hashable {
    let id: String
    let title: String
    let price: String
    let distance: String
    let category: MarketplaceCategory
    let artwork: ListingArtworkStyle
    let description: String
    let sellerID: String
    let sellerName: String
    let sellerInitials: String
    let sellerPalette: AvatarPalette
}

enum SampleMarketplace {
    static let listings: [MarketplaceListing] = [
        MarketplaceListing(
            id: "vintage-camera",
            title: "Vintage camera",
            price: "£85",
            distance: "2 miles away",
            category: .electronics,
            artwork: .vintageCamera,
            description: "A well-kept classic film camera with a bright lens and a lovely, tactile feel. Includes the original strap and is ready for its next photographer.",
            sellerID: "maya",
            sellerName: "Maya Chen",
            sellerInitials: "MC",
            sellerPalette: .violet
        ),
        MarketplaceListing(
            id: "blue-armchair",
            title: "Blue armchair",
            price: "£120",
            distance: "4 miles away",
            category: .home,
            artwork: .armchair,
            description: "A comfortable blue accent chair in very good condition. Upholstery is clean, with sturdy wooden legs. Collection from London.",
            sellerID: "james",
            sellerName: "James Carter",
            sellerInitials: "JC",
            sellerPalette: .azure
        ),
        MarketplaceListing(
            id: "road-bike",
            title: "Road bike",
            price: "£240",
            distance: "1 mile away",
            category: .vehicles,
            artwork: .roadBike,
            description: "Lightweight road bike, recently serviced and ready to ride. Shifts smoothly and includes front and rear lights.",
            sellerID: "daniel",
            sellerName: "Daniel Kim",
            sellerInitials: "DK",
            sellerPalette: .mint
        ),
        MarketplaceListing(
            id: "desk-lamp",
            title: "Desk lamp",
            price: "£28",
            distance: "3 miles away",
            category: .home,
            artwork: .deskLamp,
            description: "A warm, adjustable desk lamp with a weighted base. Works perfectly and gives a soft pool of light for reading or working.",
            sellerID: "emma",
            sellerName: "Emma Wilson",
            sellerInitials: "EW",
            sellerPalette: .amber
        )
    ]
}
