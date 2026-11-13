//
//  ComparePlansView.swift
//  FacebookUI
//
//  Monthly and yearly billing side by side, so the cheaper one is obvious.
//

import SwiftUI

/// The taller of the two plan cards, so both are drawn to the same height.
private struct CardHeightKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []

    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct ComparePlansView: View {
    @Binding var isYearly: Bool

    var onBack: () -> Void = {}

    @State private var tallestCard: CGFloat = 0

    private let monthlyPrice: Double = 250
    private let paymentsPerYear = 12

    private var yearlyPrice: Double {
        monthlyPrice * 10
    }

    private var monthlyYearTotal: Double {
        monthlyPrice * Double(paymentsPerYear)
    }

    private var yearlySaving: Double {
        monthlyYearTotal - yearlyPrice
    }

    private func money(_ value: Double) -> String {
        "£" + value.formatted(.number.precision(.fractionLength(0)))
    }

    private func renewalText(adding component: Calendar.Component, value: Int) -> String {
        let date = Calendar.current.date(byAdding: component, value: value, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    backRow
                    titleRow

                    HStack(alignment: .top, spacing: 12) {
                        planCard(isYearlyOption: false)
                        planCard(isYearlyOption: true)
                    }
                    .onPreferenceChange(CardHeightKey.self) { heights in
                        tallestCard = heights.max() ?? 0
                    }

                    Text("Both include every file and the 30% & 50% discounts.")
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
        }
        .preferredColorScheme(.dark)
    }

    private var backRow: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)
        }
    }

    private var titleRow: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Compare plans")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .accessibilityAddTraits(.isHeader)

                Text("MONTHLY OR YEARLY")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 8)

            Text("Save \(money(yearlySaving))")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.midnight)
                .padding(.horizontal, 13)
                .frame(height: 32)
                .background(Capsule().fill(Theme.cyan))
                .shadow(color: Theme.cyan.opacity(0.35), radius: 12, y: 5)
                .accessibilityLabel("Save \(money(yearlySaving)) with yearly billing")
        }
    }

    private func planCard(isYearlyOption: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isYearlyOption ? "Yearly" : "Monthly")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)

            Text(isYearlyOption ? money(yearlyPrice) : money(monthlyPrice))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 6)

            Text(isYearlyOption ? "/ year" : "/ month")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .padding(.top, 1)

            Group {
                if isYearlyOption {
                    Text("Two months free")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Theme.cyan)
                        .padding(.horizontal, 8)
                        .frame(height: 22)
                        .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                } else {
                    Color.clear
                }
            }
            .frame(height: 22, alignment: .leading)
            .padding(.top, 8)

            Text(isYearlyOption ? "Renews every year" : "Renews every month")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .padding(.top, 6)

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)
                .padding(.vertical, 12)

            VStack(alignment: .leading, spacing: 10) {
                featureRow(
                    "doc.text",
                    isYearlyOption ? "One payment a year" : "12 payments a year",
                    detail: money(isYearlyOption ? yearlyPrice : monthlyYearTotal)
                )

                featureRow(
                    "calendar",
                    "Renews \(renewalText(adding: isYearlyOption ? .year : .month, value: 1))"
                )

                featureRow("checkmark.shield", "Cancel anytime")

                if isYearlyOption {
                    featureRow(
                        "gift",
                        "You save \(money(yearlySaving))",
                        tint: Theme.cyan,
                        titleColor: Theme.cyan
                    )
                }
            }

            Spacer(minLength: 14)

            chooseButton(isYearlyOption: isYearlyOption)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: tallestCard, alignment: .top)
        .glassSurface(
            cornerRadius: 24,
            tint: Color(hex: "142846"),
            tintOpacity: isYearlyOption ? 0.74 : 0.62
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    isYearlyOption ? Theme.cyan.opacity(0.32) : Color.white.opacity(0.08),
                    lineWidth: 1
                )
        }
        .background {
            GeometryReader { proxy in
                Color.clear.preference(key: CardHeightKey.self, value: [proxy.size.height])
            }
        }
    }

    private func featureRow(
        _ symbol: String,
        _ title: String,
        detail: String? = nil,
        tint: Color = Color(hex: "AFC2DF"),
        titleColor: Color = Theme.primaryText
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(Circle().fill(tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(titleColor)
                    .fixedSize(horizontal: false, vertical: true)

                if let detail {
                    Text(detail)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(hex: "8FA3BF"))
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func chooseButton(isYearlyOption: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isYearly = isYearlyOption
            }
            onBack()
        } label: {
            Text(isYearlyOption ? "Choose yearly" : "Choose monthly")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isYearlyOption ? Theme.midnight : Theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background {
                    if isYearlyOption {
                        Capsule().fill(Theme.accent)
                    } else {
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                            .overlay {
                                Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                            }
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isYearlyOption ? "Choose yearly billing" : "Choose monthly billing")
    }
}

#Preview {
    ComparePlansView(isYearly: .constant(false))
}
