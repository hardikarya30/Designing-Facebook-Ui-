//
//  PaymentMethodView.swift
//  FacebookUI
//
//  The card the plan is charged to, and the saved cards it can use.
//

import SwiftUI

struct PaymentMethodView: View {
    @ObservedObject var store: PaymentCardsStore

    var onBack: () -> Void = {}

    @State private var isAddingCard = false
    @State private var cardName = ""
    @State private var cardNumber = ""
    @State private var cardExpiry = ""

    private var cardsCountText: String {
        let count = store.cards.count
        return count == 1 ? "1 card" : "\(count) cards"
    }

    private var canSave: Bool {
        cardNumber.filter(\.isNumber).count >= 4
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    Text("Saved cards")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                        .padding(.leading, 4)

                    VStack(spacing: 8) {
                        ForEach(store.cards) { card in
                            cardRow(card)
                        }

                        addCardRow
                    }

                    if isAddingCard {
                        addCardForm
                    }

                    Text("Charges are taken on the renewal date.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "91A8C8"))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 14) {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 3) {
                Text("Payment method")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text("FOR YOUR PLAN")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)

            Text(cardsCountText)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(Capsule().fill(Theme.cyan.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.28), lineWidth: 1))
                .accessibilityLabel(cardsCountText)
        }
    }

    private func cardRow(_ card: PaymentCard) -> some View {
        let isSelected = card.id == store.selectedID

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                store.select(card)
            }
        } label: {
            HStack(spacing: 12) {
                cardTile(for: card)

                VStack(alignment: .leading, spacing: 3) {
                    Text(card.label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)

                    Text(card.expiry.isEmpty ? "Expiry not set" : "Expires \(card.expiry)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .accessibilityLabel("In use")
                } else {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(paymentLabel(for: card)), \(card.expiry.isEmpty ? "expiry not set" : "expires \(card.expiry)")")
        .accessibilityValue(isSelected ? "In use" : "Not in use")
    }

    private func cardTile(for card: PaymentCard) -> some View {
        let colors: [Color] = card.brand == "Mastercard"
            ? [Color(hex: "243A6E"), Color(hex: "4A7BB0")]
            : [Color(hex: "263B78"), Color(hex: "6B3B82")]

        return RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 44, height: 32)
            .overlay {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            }
    }

    private var addCardRow: some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.85)) {
                isAddingCard.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Theme.cyan.opacity(0.14)))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Add card")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Pay with a new card")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 0)

                Image(systemName: isAddingCard ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.5, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add card")
    }

    private var addCardForm: some View {
        VStack(spacing: 10) {
            TextField("Name on card", text: $cardName)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
                .accessibilityLabel("Name on card")

            TextField("Card number", text: $cardNumber)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .keyboardType(.numberPad)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
                .accessibilityLabel("Card number")

            TextField("Expiry", text: $cardExpiry)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .keyboardType(.numbersAndPunctuation)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
                .accessibilityLabel("Expiry")

            Button(action: saveCard) {
                Text("Save card")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.midnight)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Capsule().fill(Theme.accent))
                    .shadow(color: Theme.cyan.opacity(0.28), radius: 12, y: 5)
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.45)
            .accessibilityLabel("Save card")
        }
        .padding(12)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
        .transition(.opacity)
    }

    private func saveCard() {
        guard store.addCard(number: cardNumber, expiry: cardExpiry) != nil else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.85)) {
            isAddingCard = false
        }

        cardName = ""
        cardNumber = ""
        cardExpiry = ""
    }

    private func paymentLabel(for card: PaymentCard) -> String {
        card.label
    }
}

#Preview {
    PaymentMethodView(store: PaymentCardsStore())
}
