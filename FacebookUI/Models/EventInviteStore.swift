//
//  EventInviteStore.swift
//  FacebookUI
//
//  Remembers which friends you invited to each event.
//

import Combine
import Foundation

final class EventInviteStore: ObservableObject {

    @Published private(set) var invites: [String: [String]]

    private let defaults: UserDefaults
    private let storageKey = "events.invites"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "events.invites"),
           let saved = try? JSONDecoder().decode([String: [String]].self, from: data) {
            invites = saved
        } else {
            invites = [:]
        }
    }

    func invitedIDs(for event: SocialEvent) -> Set<String> {
        Set(invites[event.id] ?? [])
    }

    func send(_ friendIDs: Set<String>, for event: SocialEvent) {
        guard !friendIDs.isEmpty else { return }

        let existing = invitedIDs(for: event)
        invites[event.id] = Array(existing.union(friendIDs)).sorted()

        if let data = try? JSONEncoder().encode(invites) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
