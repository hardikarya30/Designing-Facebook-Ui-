//
//  SavedVenuesStore.swift
//  FacebookUI
//
//  Keeps the venues you saved, written to disk when the list changes.
//

import Combine
import Foundation

final class SavedVenuesStore: ObservableObject {

    @Published private(set) var savedIDs: [String]
    @Published private(set) var visitedIDs: Set<String>
    @Published private(set) var remindedIDs: Set<String>
    /// The places you added yourself, kept beside the sample venues.
    @Published private(set) var customVenues: [Venue]

    private let defaults: UserDefaults
    private let storageKey = "venues.savedIDs"
    private let visitedStorageKey = "venues.visitedIDs"
    private let remindedStorageKey = "venues.remindedIDs"
    private let customStorageKey = "venues.custom"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let stored = defaults.stringArray(forKey: "venues.savedIDs") {
            savedIDs = stored
        } else {
            savedIDs = SampleVenues.defaultSavedIDs
        }

        visitedIDs = Set(defaults.stringArray(forKey: "venues.visitedIDs") ?? [])
        remindedIDs = Set(defaults.stringArray(forKey: "venues.remindedIDs") ?? [])

        if let data = defaults.data(forKey: "venues.custom"),
           let decoded = try? JSONDecoder().decode([Venue].self, from: data) {
            customVenues = decoded
        } else {
            customVenues = []
        }
    }

    /// Every venue the app knows about: the samples and the ones you added.
    var knownVenues: [Venue] {
        SampleVenues.all + customVenues
    }

    func venue(with id: String) -> Venue? {
        knownVenues.first { $0.id == id }
    }

    var venues: [Venue] {
        savedIDs.compactMap { venue(with: $0) }
    }

    func isSaved(_ venue: Venue) -> Bool {
        savedIDs.contains(venue.id)
    }

    func save(_ venue: Venue) {
        guard !isSaved(venue) else { return }
        savedIDs.append(venue.id)
        persist()
    }

    func remove(_ venue: Venue) {
        savedIDs.removeAll { $0 == venue.id }
        persist()
    }

    /// Saves a place you typed in yourself, pinned just beside your home address.
    @discardableResult
    func addVenue(name: String, area: String, address: String) -> Venue {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArea = area.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)

        // Each new place sits a little further round the home address, so the pins
        // on the venues map do not land on top of one another.
        let step = Double(customVenues.count % 4 + 1) * 0.0045

        let venue = Venue(
            id: "custom-\(UUID().uuidString.prefix(8))",
            name: trimmedName,
            area: trimmedArea,
            address: trimmedAddress,
            symbol: "mappin.and.ellipse",
            colors: ["3B2C74", "8B6BE0"],
            matchTerms: [trimmedName],
            latitude: EventLocations.homeCoordinate.latitude + step,
            longitude: EventLocations.homeCoordinate.longitude - step * 0.8
        )

        customVenues.append(venue)
        persistCustomVenues()

        savedIDs.append(venue.id)
        persist()

        return venue
    }

    func isVisited(_ venue: Venue) -> Bool {
        visitedIDs.contains(venue.id)
    }

    func toggleVisited(_ venue: Venue) {
        if isVisited(venue) {
            visitedIDs.remove(venue.id)
        } else {
            visitedIDs.insert(venue.id)
        }
        defaults.set(Array(visitedIDs).sorted(), forKey: visitedStorageKey)
    }

    func isReminded(_ venue: Venue) -> Bool {
        remindedIDs.contains(venue.id)
    }

    func toggleReminder(_ venue: Venue) {
        if isReminded(venue) {
            remindedIDs.remove(venue.id)
        } else {
            remindedIDs.insert(venue.id)
        }
        defaults.set(Array(remindedIDs).sorted(), forKey: remindedStorageKey)
    }

    private func persist() {
        defaults.set(savedIDs, forKey: storageKey)
    }

    private func persistCustomVenues() {
        guard let data = try? JSONEncoder().encode(customVenues) else { return }
        defaults.set(data, forKey: customStorageKey)
    }
}
