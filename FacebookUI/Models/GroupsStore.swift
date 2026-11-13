//
//  GroupsStore.swift
//  FacebookUI
//
//  Keeps group membership and join requests on disk.
//

import Combine
import Foundation

final class GroupsStore: ObservableObject {
    @Published private(set) var joinedIDs: Set<String>
    @Published private(set) var requestedIDs: Set<String>

    private let defaults: UserDefaults
    private let joinedKey = "groups.joinedIDs"
    private let requestedKey = "groups.requestedIDs"

    let groups = SampleGroups.all

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        joinedIDs = Set(defaults.stringArray(forKey: "groups.joinedIDs") ?? [])
        requestedIDs = Set(defaults.stringArray(forKey: "groups.requestedIDs") ?? [])
    }

    func isJoined(_ group: SocialGroup) -> Bool {
        joinedIDs.contains(group.id)
    }

    func isRequested(_ group: SocialGroup) -> Bool {
        requestedIDs.contains(group.id)
    }

    func toggleMembership(for group: SocialGroup) {
        if isJoined(group) {
            joinedIDs.remove(group.id)
        } else {
            joinedIDs.insert(group.id)
        }
        defaults.set(Array(joinedIDs), forKey: joinedKey)
    }

    func toggleRequest(for group: SocialGroup) {
        if isRequested(group) {
            requestedIDs.remove(group.id)
        } else {
            requestedIDs.insert(group.id)
        }
        defaults.set(Array(requestedIDs), forKey: requestedKey)
    }
}
