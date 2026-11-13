//
//  ProfileStore.swift
//  FacebookUI
//
//  The profile model, written to disk on every edit so edits survive
//  a relaunch.
//

import Combine
import Foundation

final class ProfileStore: ObservableObject {

    @Published private(set) var profile: Profile

    private let defaults: UserDefaults
    private let storageKey = "profile.current"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "profile.current"),
           let saved = try? JSONDecoder().decode(Profile.self, from: data) {
            self.profile = Self.migratedIdentity(saved, defaults: defaults)
        } else {
            self.profile = SampleProfile.profile
        }
    }

    /// Brings a profile written by an earlier build up to the current name,
    /// username and role without touching anything the user edited.
    private static func migratedIdentity(_ saved: Profile, defaults: UserDefaults) -> Profile {
        var updated = saved

        if updated.name == "Alex Morgan" || updated.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updated.name = "Hardik Arya"
        }
        if updated.handle == "@alexmorgan" || updated.handle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updated.handle = "@hafreelancers"
        }
        if updated.role == "Designer, Studio 27" || updated.role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updated.role = "Designer, System Studio"
        }
        if updated.work == "Studio 27 · Product Design" {
            updated.work = ""
        }

        if updated != saved, let data = try? JSONEncoder().encode(updated) {
            defaults.set(data, forKey: "profile.current")
        }
        return updated
    }

    func update(_ updated: Profile) {
        profile = updated
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
