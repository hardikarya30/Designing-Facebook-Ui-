//
//  EventDiscussionStore.swift
//  FacebookUI
//
//  Keeps the messages you post in each event's discussion on this device.
//

import Combine
import Foundation

final class EventDiscussionStore: ObservableObject {

    @Published private(set) var threads: [String: [EventDiscussionMessage]]

    private let defaults: UserDefaults
    private let storageKey = "events.discussion"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "events.discussion"),
           let saved = try? JSONDecoder().decode([String: [EventDiscussionMessage]].self, from: data) {
            threads = saved
        } else {
            threads = [:]
        }
    }

    func messages(for event: SocialEvent) -> [EventDiscussionMessage] {
        SampleEventDiscussion.messages(for: event) + (threads[event.id] ?? [])
    }

    func send(_ text: String, in event: SocialEvent, authorName: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let name = authorName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = name.isEmpty ? "You" : name
        let initials = resolvedName
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()

        let message = EventDiscussionMessage(
            id: UUID().uuidString,
            authorName: resolvedName,
            initials: initials.isEmpty ? "Y" : initials,
            palette: .cyan,
            text: trimmed,
            createdAt: Date(),
            isMine: true
        )

        threads[event.id, default: []].append(message)

        if let data = try? JSONEncoder().encode(threads) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
