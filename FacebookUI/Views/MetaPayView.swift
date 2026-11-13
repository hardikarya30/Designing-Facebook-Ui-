//
//  MetaPayView.swift
//  FacebookUI
//
//  The wallet: a card, a balance and the available payment methods.
//

import SwiftUI

private struct WalletPaymentOption: Identifiable {
    let title: String
    let icon: String
    let tint: Color

    var id: String { title }

    static let all: [WalletPaymentOption] = [
        WalletPaymentOption(title: "Google Play", icon: "play.fill", tint: Color(hex: "34D399")),
        WalletPaymentOption(title: "Apple Pay", icon: "apple.logo", tint: .white),
        WalletPaymentOption(title: "PayPal", icon: "p.circle.fill", tint: Color(hex: "60A5FA")),
        WalletPaymentOption(title: "Bank card", icon: "creditcard.fill", tint: Theme.cyan),
        WalletPaymentOption(title: "Credit card", icon: "creditcard.fill", tint: Theme.violet),
        WalletPaymentOption(title: "Debit card", icon: "creditcard.fill", tint: Color(hex: "7AA7FF")),
        WalletPaymentOption(title: "Online banking", icon: "building.columns.fill", tint: Theme.cyan)
    ]
}

private struct WalletPaymentMethod: Identifiable {
    let id: String
    let title: String
    let detail: String?
    let icon: String
    let tint: Color
}

struct MetaPayView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var hasCard = true
    @State private var isAddMethodPresented = false
    @State private var addedMethods: [WalletPaymentMethod] = []

    private let savedMethods = [
        WalletPaymentMethod(
            id: "visa",
            title: "Visa •••• 4821",
            detail: "Expires 09/29",
            icon: "creditcard.fill",
            tint: Color(hex: "77A8FF")
        ),
        WalletPaymentMethod(
            id: "chase",
            title: "Chase •••• 1102",
            detail: nil,
            icon: "building.columns.fill",
            tint: Color(hex: "77A8FF")
        )
    ]

    private var paymentMethods: [WalletPaymentMethod] {
        savedMethods + addedMethods
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if hasCard {
                        cardView
                            .transition(.scale(scale: 0.94).combined(with: .opacity))
                    } else {
                        emptyCard
                    }

                    balanceRow
                    methodsSection

                    Color.clear
                        .frame(height: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: hasCard)
        .sheet(isPresented: $isAddMethodPresented) {
            PaymentOptionsSheet { option in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    addedMethods.append(
                        WalletPaymentMethod(
                            id: UUID().uuidString,
                            title: option.title,
                            detail: "Payment option selected",
                            icon: option.icon,
                            tint: option.tint
                        )
                    )
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Back")

            Spacer()

            Menu {
                Button(role: .destructive) {
                    hasCard = false
                } label: {
                    Label("Remove card", systemImage: "trash")
                }
                .disabled(!hasCard)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .glassSurface(cornerRadius: 20, tintOpacity: 0.62)
                    .contentShape(Circle())
            }
            .accessibilityLabel("Card options")
        }
        .overlay {
            Text("Meta Pay")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .allowsHitTesting(false)
        }
        .padding(.bottom, 6)
    }

    // MARK: - Card

    private var cardView: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1260F4"), Color(hex: "06245E"), Color(hex: "312A9E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .fill(Theme.cyan.opacity(0.48))
                    .frame(width: proxy.size.width * 0.62)
                    .blur(radius: 52)
                    .offset(x: -proxy.size.width * 0.25, y: -proxy.size.height * 0.35)

                Circle()
                    .fill(Color(hex: "D56AFF").opacity(0.66))
                    .frame(width: proxy.size.width * 0.68)
                    .blur(radius: 48)
                    .offset(x: proxy.size.width * 0.53, y: -proxy.size.height * 0.72)

                WalletCardWave()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FF9BFA").opacity(0.8), Color(hex: "A78BFA").opacity(0.48), Color(hex: "178BFF").opacity(0.18)],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )

                WalletCardShine()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Theme.cyan.opacity(0.55), Color.white.opacity(0.04)],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .blur(radius: 1.2)

                VStack(alignment: .leading, spacing: 0) {
                    WalletChip()
                        .frame(width: 44, height: 34)

                    Spacer(minLength: 0)

                    Text("•••• 4821")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.96))
                        .monospacedDigit()

                    Text("Hardik Arya")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .padding(.top, 5)
                }
                .padding(20)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: Color(hex: "267EFF").opacity(0.28), radius: 22, y: 12)
        }
        .aspectRatio(1.7, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Payment card ending in 4821, Hardik Arya")
    }

    private var emptyCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "creditcard")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.accent)

            Text("No card added")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Add a payment method below.")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }

    // MARK: - Balance

    private var balanceRow: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("$0.00")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .monospacedDigit()

                Text("Balance")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            Rectangle()
                .fill(Theme.hairline)
                .frame(width: 1, height: 48)

            Button {} label: {
                Text("Add money")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(Capsule(style: .continuous).fill(Theme.accent))
                    .shadow(color: Theme.cyan.opacity(0.3), radius: 12, y: 5)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassSurface(cornerRadius: 22, tintOpacity: 0.58)
    }

    // MARK: - Methods

    private var methodsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PAYMENT METHODS")
                .font(.system(size: 11, weight: .bold))
                .tracking(3)
                .foregroundStyle(Theme.tertiaryText)
                .padding(.leading, 2)

            VStack(spacing: 0) {
                ForEach(Array(paymentMethods.enumerated()), id: \.element.id) { index, method in
                    methodRow(method)

                    if index < paymentMethods.count - 1 {
                        divider
                    }
                }

                if !paymentMethods.isEmpty {
                    divider
                }

                addMethodRow
            }
            .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.58)
        }
    }

    private func methodRow(_ method: WalletPaymentMethod) -> some View {
        HStack(spacing: 16) {
            Image(systemName: method.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(method.tint)
                .frame(width: 44, height: 44)
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                        .overlay {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        }
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(method.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                if let detail = method.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "9DB7E5"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var addMethodRow: some View {
        Button {
            isAddMethodPresented = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "plus")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.accent))
                    .shadow(color: Theme.cyan.opacity(0.3), radius: 10, y: 4)

                Text("Add payment method")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.primaryText)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "9DB7E5"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add payment method")
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1)
            .padding(.leading, 76)
            .padding(.trailing, 16)
    }
}

private struct PaymentOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (WalletPaymentOption) -> Void

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Add payment method")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Spacer()

                    GlassIconButton(systemName: "xmark", size: 36) {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(WalletPaymentOption.all.enumerated()), id: \.element.id) { index, option in
                            Button {
                                onSelect(option)
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: option.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(option.tint)
                                        .frame(width: 42, height: 42)
                                        .background(Circle().fill(Color.white.opacity(0.07)))

                                    Text(option.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.primaryText)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Theme.tertiaryText)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if index < WalletPaymentOption.all.count - 1 {
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(height: 1)
                                    .padding(.leading, 70)
                                    .padding(.trailing, 14)
                            }
                        }
                    }
                    .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.58)
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(.dark)
    }
}

private struct WalletCardWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.62, y: 0))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.1),
            control1: CGPoint(x: rect.width * 0.82, y: 0),
            control2: CGPoint(x: rect.width, y: rect.height * 0.01)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.37))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.49, y: rect.height * 0.72),
            control1: CGPoint(x: rect.width * 0.83, y: rect.height * 0.56),
            control2: CGPoint(x: rect.width * 0.61, y: rect.height * 0.59)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.37, y: rect.height),
            control1: CGPoint(x: rect.width * 0.36, y: rect.height * 0.82),
            control2: CGPoint(x: rect.width * 0.34, y: rect.height * 0.92)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct WalletCardShine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width, y: rect.height * 0.37))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.49, y: rect.height * 0.72),
            control1: CGPoint(x: rect.width * 0.83, y: rect.height * 0.56),
            control2: CGPoint(x: rect.width * 0.61, y: rect.height * 0.59)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.37, y: rect.height),
            control1: CGPoint(x: rect.width * 0.36, y: rect.height * 0.82),
            control2: CGPoint(x: rect.width * 0.34, y: rect.height * 0.92)
        )
        return path
    }
}

private struct WalletChip: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.92), Color(hex: "B8C9E1").opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                WalletChipPattern()
                    .stroke(Color(hex: "667B9C").opacity(0.72), lineWidth: 1)
                    .padding(1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.44), lineWidth: 1)
            }
    }
}

private struct WalletChipPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let third = rect.width / 3
        let middle = rect.height / 2

        path.move(to: CGPoint(x: third, y: 0))
        path.addLine(to: CGPoint(x: third, y: rect.height))
        path.move(to: CGPoint(x: third * 2, y: 0))
        path.addLine(to: CGPoint(x: third * 2, y: rect.height))
        path.move(to: CGPoint(x: 0, y: middle))
        path.addLine(to: CGPoint(x: rect.width, y: middle))
        path.addRoundedRect(
            in: CGRect(x: third + 2, y: middle * 0.45, width: third - 4, height: middle * 1.1),
            cornerSize: CGSize(width: 2, height: 2)
        )
        return path
    }
}

#Preview {
    MetaPayView()
}
