//
//  PlanHistoryStore.swift
//  FacebookUI
//
//  Keeps the changes made to the plan — pauses, resumes and billing switches —
//  written to disk as they happen.
//

import Combine
import Foundation

struct PlanHistoryRecord: Codable, Identifiable, Hashable {
    enum Kind: String, Codable {
        case pause
        case resume
        case change
    }

    let id: String
    let date: Date
    let kind: Kind
    let detail: String

    init(kind: Kind, detail: String, date: Date = Date()) {
        self.id = UUID().uuidString
        self.date = date
        self.kind = kind
        self.detail = detail
    }
}

final class PlanHistoryStore: ObservableObject {

    @Published private(set) var records: [PlanHistoryRecord]

    private let defaults: UserDefaults
    private let storageKey = "plan.history"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "plan.history"),
           let stored = try? JSONDecoder().decode([PlanHistoryRecord].self, from: data) {
            records = stored
        } else {
            records = []
        }
    }

    func recordPause() {
        record(.pause, "Paused the plan for a month")
    }

    func recordResume() {
        record(.resume, "Resumed the plan")
    }

    func recordBillingChange(toYearly: Bool) {
        record(.change, toYearly ? "Switched to yearly billing" : "Switched to monthly billing")
    }

    private func record(_ kind: PlanHistoryRecord.Kind, _ detail: String) {
        records.append(PlanHistoryRecord(kind: kind, detail: detail))

        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
