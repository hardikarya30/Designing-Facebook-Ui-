//
//  PaymentNotes.swift
//  FacebookUI
//
//  Short notes kept on each charge's receipt, filed by invoice number.
//

import Combine
import Foundation

final class PaymentNotesStore: ObservableObject {

    @Published private(set) var notes: [String: String]

    private let defaults: UserDefaults
    private let storageKey = "plan.notes"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        notes = (defaults.dictionary(forKey: "plan.notes") as? [String: String]) ?? [:]
    }

    func note(for invoiceNumber: String) -> String {
        notes[invoiceNumber] ?? ""
    }

    func hasNote(for invoiceNumber: String) -> Bool {
        !(notes[invoiceNumber] ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    /// An empty note clears the entry, so the receipt's badge goes away again.
    func setNote(_ text: String, for invoiceNumber: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notes.removeValue(forKey: invoiceNumber)
        } else {
            notes[invoiceNumber] = text
        }

        defaults.set(notes, forKey: storageKey)
    }
}
