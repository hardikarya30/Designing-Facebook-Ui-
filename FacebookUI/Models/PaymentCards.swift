//
//  PaymentCards.swift
//  FacebookUI
//
//  The cards the plan can be charged to, with the one in use kept on this device.
//

import Combine
import Foundation

struct PaymentCard: Codable, Identifiable, Hashable {
    let id: String
    let brand: String
    let lastFour: String
    let expiry: String

    /// "Visa ending 4242", the way receipts show it.
    var label: String {
        "\(brand) ending \(lastFour)"
    }
}

final class PaymentCardsStore: ObservableObject {

    @Published private(set) var cards: [PaymentCard]
    @Published private(set) var selectedID: String?

    private let defaults: UserDefaults
    private let cardsKey = "plan.cards"
    private let selectedKey = "plan.selectedCardID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: "plan.cards"),
           let stored = try? JSONDecoder().decode([PaymentCard].self, from: data) {
            cards = stored
        } else {
            cards = [
                PaymentCard(id: "visa-4242", brand: "Visa", lastFour: "4242", expiry: "04/27"),
                PaymentCard(id: "mastercard-8810", brand: "Mastercard", lastFour: "8810", expiry: "11/26")
            ]
        }

        let storedID = defaults.string(forKey: "plan.selectedCardID")
        selectedID = storedID ?? cards.first?.id
        if selectedID == nil {
            selectedID = cards.first?.id
        }
    }

    var selectedCard: PaymentCard? {
        cards.first { $0.id == selectedID }
    }

    func select(_ card: PaymentCard) {
        selectedID = card.id
        defaults.set(card.id, forKey: selectedKey)
    }

    /// Adds a card from the number typed in, choosing its brand from the first digit.
    @discardableResult
    func addCard(number: String, expiry: String) -> PaymentCard? {
        let digits = number.filter(\.isNumber)
        guard digits.count >= 4 else { return nil }

        let brand: String
        if digits.hasPrefix("4") {
            brand = "Visa"
        } else if digits.hasPrefix("5") {
            brand = "Mastercard"
        } else {
            brand = "Card"
        }

        let card = PaymentCard(
            id: UUID().uuidString,
            brand: brand,
            lastFour: String(digits.suffix(4)),
            expiry: expiry.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        cards.append(card)
        selectedID = card.id
        persist()
        defaults.set(card.id, forKey: selectedKey)
        return card
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(cards) {
            defaults.set(data, forKey: cardsKey)
        }
    }
}
