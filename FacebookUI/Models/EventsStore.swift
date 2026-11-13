//
//  EventsStore.swift
//  FacebookUI
//
//  Persists sample and user-created events, bookmarks and RSVPs on this device.
//

import Combine
import Foundation

final class EventsStore: ObservableObject {
    @Published private(set) var responses: [String: EventRSVP]
    @Published private(set) var events: [SocialEvent]
    @Published private(set) var savedIDs: Set<String>
    @Published private(set) var declinedIDs: Set<String>
    @Published private(set) var remindedIDs: Set<String>
    @Published private(set) var pinnedID: String?
    @Published private(set) var ratings: [String: Int]

    private var createdEvents: [SocialEvent]
    private let defaults: UserDefaults
    private let responsesKey = "events.rsvpResponses"
    private let createdEventsKey = "events.createdEvents"
    private let savedEventsKey = "events.savedIDs"
    private let declinedEventsKey = "events.declinedIDs"
    private let remindersKey = "events.reminders"
    private let pinnedEventKey = "events.pinnedID"
    private let ratingsKey = "events.ratings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedValues = defaults.dictionary(forKey: "events.rsvpResponses") as? [String: String] ?? [:]
        responses = storedValues.compactMapValues(EventRSVP.init(rawValue:))
        savedIDs = Set(defaults.stringArray(forKey: "events.savedIDs") ?? [])
        declinedIDs = Set(defaults.stringArray(forKey: "events.declinedIDs") ?? [])
        remindedIDs = Set(defaults.stringArray(forKey: "events.reminders") ?? [])
        pinnedID = defaults.string(forKey: "events.pinnedID")
        ratings = (defaults.dictionary(forKey: "events.ratings") as? [String: Int]) ?? [:]

        if let data = defaults.data(forKey: "events.createdEvents"),
           let savedEvents = try? JSONDecoder().decode([SocialEvent].self, from: data) {
            createdEvents = savedEvents
        } else {
            createdEvents = []
        }
        events = (SampleEvents.events + createdEvents).sorted { $0.date < $1.date }
    }

    var savedEvents: [SocialEvent] {
        events.filter { savedIDs.contains($0.id) }
    }

    func response(for event: SocialEvent) -> EventRSVP? {
        responses[event.id]
    }

    func setResponse(_ response: EventRSVP?, for event: SocialEvent) {
        responses[event.id] = response
        if response == nil {
            responses.removeValue(forKey: event.id)
        }
        defaults.set(responses.mapValues(\.rawValue), forKey: responsesKey)
    }

    func isSaved(_ event: SocialEvent) -> Bool {
        savedIDs.contains(event.id)
    }

    func toggleSaved(_ event: SocialEvent) {
        if isSaved(event) {
            savedIDs.remove(event.id)
        } else {
            savedIDs.insert(event.id)
        }
        defaults.set(Array(savedIDs).sorted(), forKey: savedEventsKey)
    }

    /// Invitations the user has declined stay hidden from Invites across launches.
    func isDeclined(_ event: SocialEvent) -> Bool {
        declinedIDs.contains(event.id)
    }

    func decline(_ event: SocialEvent) {
        declinedIDs.insert(event.id)
        defaults.set(Array(declinedIDs).sorted(), forKey: declinedEventsKey)
    }

    var invitationCount: Int {
        events.filter { $0.isInvitation && !declinedIDs.contains($0.id) }.count
    }

    func isReminded(_ event: SocialEvent) -> Bool {
        remindedIDs.contains(event.id)
    }

    func toggleReminder(_ event: SocialEvent) {
        if isReminded(event) {
            remindedIDs.remove(event.id)
        } else {
            remindedIDs.insert(event.id)
        }
        defaults.set(Array(remindedIDs).sorted(), forKey: remindersKey)
    }

    /// Reminders fire at 6pm the evening before the event.
    func reminderDate(for event: SocialEvent) -> Date {
        let calendar = Calendar.current
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: event.date) ?? event.date
        return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: dayBefore) ?? dayBefore
    }

    /// Only one event can be pinned to the top of Upcoming at a time.
    func isPinned(_ event: SocialEvent) -> Bool {
        pinnedID == event.id
    }

    func togglePin(_ event: SocialEvent) {
        pinnedID = isPinned(event) ? nil : event.id

        if let pinnedID {
            defaults.set(pinnedID, forKey: pinnedEventKey)
        } else {
            defaults.removeObject(forKey: pinnedEventKey)
        }
    }

    /// Your 1–5 star rating of an event that has already happened.
    func rating(for event: SocialEvent) -> Int {
        ratings[event.id] ?? 0
    }

    func setRating(_ rating: Int, for event: SocialEvent) {
        let clamped = min(max(rating, 1), 5)
        ratings[event.id] = clamped
        defaults.set(ratings, forKey: ratingsKey)
    }

    func addEvent(_ event: SocialEvent) {
        guard !events.contains(where: { $0.id == event.id }) else { return }
        createdEvents.append(event)
        events = (SampleEvents.events + createdEvents).sorted { $0.date < $1.date }
        if let data = try? JSONEncoder().encode(createdEvents) {
            defaults.set(data, forKey: createdEventsKey)
        }
    }
}
