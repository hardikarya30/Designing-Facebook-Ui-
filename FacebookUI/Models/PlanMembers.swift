//
//  PlanMembers.swift
//  FacebookUI
//
//  The friends who share the plan, and whether they have joined yet.
//

import Combine
import Foundation

struct PlanInvitee: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let palette: AvatarPalette
}

final class PlanMembersStore: ObservableObject {

    @Published private(set) var invited: [PlanInvitee]

    private let defaults: UserDefaults
    private let storageKey = "plan.members"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "plan.members"),
           let decoded = try? JSONDecoder().decode([PlanInvitee].self, from: data) {
            invited = decoded
        } else {
            invited = []
        }
    }

    /// You plus everyone you have invited, whether or not they have joined.
    var peopleCount: Int {
        invited.count + 1
    }

    func isInvited(_ friendID: String) -> Bool {
        invited.contains { $0.id == friendID }
    }

    /// Adds the picked friends as invited; anyone already on the plan is left alone.
    func invite(_ friends: [InviteFriend]) {
        for friend in friends where !isInvited(friend.id) {
            invited.append(
                PlanInvitee(
                    id: friend.id,
                    name: friend.name,
                    initials: friend.initials,
                    palette: friend.palette
                )
            )
        }

        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(invited) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
