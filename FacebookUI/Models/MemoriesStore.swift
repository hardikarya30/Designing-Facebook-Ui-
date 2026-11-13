//
//  MemoriesStore.swift
//  FacebookUI
//
//  Keeps memory bookmarks on this device.
//

import Combine
import Foundation

final class MemoriesStore: ObservableObject {
    @Published private(set) var savedIDs: Set<String>

    private let defaults: UserDefaults
    private let savedKey = "memories.savedIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        savedIDs = Set(defaults.stringArray(forKey: "memories.savedIDs") ?? [])
    }

    func isSaved(_ memory: Memory) -> Bool {
        savedIDs.contains(memory.id)
    }

    func toggleSaved(_ memory: Memory) {
        if isSaved(memory) {
            savedIDs.remove(memory.id)
        } else {
            savedIDs.insert(memory.id)
        }
        defaults.set(Array(savedIDs), forKey: savedKey)
    }
}
