//
//  AddressStore.swift
//  FacebookUI
//
//  Your saved home address, written to disk when it changes.
//

import Combine
import Foundation

final class AddressStore: ObservableObject {

    @Published private(set) var lines: [String]
    @Published private(set) var workLines: [String]

    private let defaults: UserDefaults
    private let storageKey = "profile.addressLines"
    private let workStorageKey = "profile.workAddressLines"

    static let defaultLines = [
        "Flat 7",
        "Jeffery House",
        "450 London Road",
        "North Cheam",
        "South London",
        "Surrey",
        "SM3 8JB",
        "United Kingdom"
    ]

    static let defaultWorkLines = [
        "Studio 27",
        "12 Rivington Street",
        "Shoreditch",
        "London",
        "EC2A 3DU",
        "United Kingdom"
    ]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let saved = defaults.stringArray(forKey: "profile.addressLines"), !saved.isEmpty {
            lines = saved
        } else {
            lines = Self.defaultLines
        }

        if let savedWork = defaults.stringArray(forKey: "profile.workAddressLines"), !savedWork.isEmpty {
            workLines = savedWork
        } else {
            workLines = Self.defaultWorkLines
        }
    }

    var fullAddress: String {
        lines.joined(separator: ", ")
    }

    /// "North Cheam · United Kingdom" for the screen's subtitle.
    var areaLine: String {
        guard lines.count > 3 else { return lines.last ?? "" }
        return "\(lines[3]) · \(lines[lines.count - 1])"
    }

    /// The postcode-like line, used for the badge on the map.
    var postcode: String {
        Self.postcode(in: lines)
    }

    var workFullAddress: String {
        workLines.joined(separator: ", ")
    }

    /// "Shoreditch · United Kingdom" for the work card.
    var workAreaLine: String {
        guard workLines.count > 3 else { return workLines.last ?? "" }
        return "\(workLines[3]) · \(workLines[workLines.count - 1])"
    }

    var workPostcode: String {
        Self.postcode(in: workLines)
    }

    func update(_ newLines: [String]) {
        let cleaned = newLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        lines = cleaned.isEmpty ? Self.defaultLines : cleaned
        defaults.set(lines, forKey: storageKey)
    }

    func updateWork(_ newLines: [String]) {
        let cleaned = newLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        workLines = cleaned.isEmpty ? Self.defaultWorkLines : cleaned
        defaults.set(workLines, forKey: workStorageKey)
    }

    /// Re-reads the addresses, for a screen whose copy may have been edited elsewhere.
    func refresh() {
        if let saved = defaults.stringArray(forKey: storageKey), !saved.isEmpty {
            lines = saved
        }
        if let savedWork = defaults.stringArray(forKey: workStorageKey), !savedWork.isEmpty {
            workLines = savedWork
        }
    }

    private static func postcode(in lines: [String]) -> String {
        lines.last { line in
            line.contains(where: \.isNumber)
                && line.uppercased() == line
                && line.count <= 8
        } ?? ""
    }
}
