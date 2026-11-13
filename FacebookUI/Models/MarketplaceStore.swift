//
//  MarketplaceStore.swift
//  FacebookUI
//
//  Keeps locally saved Marketplace listings across launches.
//

import Combine
import Foundation

final class MarketplaceStore: ObservableObject {
    @Published private(set) var savedIDs: Set<String>

    let listings = SampleMarketplace.listings

    private let defaults: UserDefaults
    private let savedKey = "marketplace.savedListingIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        savedIDs = Set(defaults.stringArray(forKey: "marketplace.savedListingIDs") ?? [])
    }

    func isSaved(_ listing: MarketplaceListing) -> Bool {
        savedIDs.contains(listing.id)
    }

    func toggleSaved(_ listing: MarketplaceListing) {
        if isSaved(listing) {
            savedIDs.remove(listing.id)
        } else {
            savedIDs.insert(listing.id)
        }
        defaults.set(Array(savedIDs), forKey: savedKey)
    }
}
