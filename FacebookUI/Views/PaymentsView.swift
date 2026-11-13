//
//  PaymentsView.swift
//  FacebookUI
//
//  This year's plan charges, newest first.
//

import SwiftUI

private struct PlanPayment: Identifiable {
    let id: String
    let date: Date
    let amount: Double

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct PaymentsView: View {
    @ObservedObject var cards: PaymentCardsStore
    @ObservedObject var notes: PaymentNotesStore

    var vatNumber: String = ""
    var onBack: () -> Void = {}
    var stores: EventStores? = nil

    @State private var selectedPayment: PlanPayment?
    @State private var exportURL: URL?
    @State private var searchText = ""
    @State private var selectedSpendMonth: Int?

    private struct MonthSpend: Identifiable {
        let month: Int
        let amount: Double

        var id: Int { month }

        var letter: String {
            String(Calendar.current.shortMonthSymbols[month - 1].prefix(1))
        }
    }

    private let monthlyAmount: Double = 250

    private var payments: [PlanPayment] {
        let calendar = Calendar.current
        let now = Date()

        guard let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let currentMonth = calendar.dateComponents([.month], from: now).month else {
            return []
        }

        return (1...currentMonth).reversed().compactMap { month in
            guard let date = calendar.date(byAdding: .month, value: month - 1, to: yearStart) else {
                return nil
            }
            return PlanPayment(
                id: "\(calendar.component(.year, from: now))-\(month)",
                date: date,
                amount: monthlyAmount
            )
        }
    }

    private var totalText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_GB")
        formatter.maximumFractionDigits = 0
        let total = payments.reduce(0) { $0 + $1.amount }
        return "£" + (formatter.string(from: NSNumber(value: total)) ?? "0")
    }

    private var amountText: String {
        String(format: "£%.0f", monthlyAmount)
    }

    private var paymentsCountText: String {
        payments.count == 1 ? "/ 1 payment" : "/ \(payments.count) payments"
    }

    /// Charges matching the search, by date, amount or the note kept on the receipt.
    private var filteredPayments: [PlanPayment] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return payments }

        return payments.filter { payment in
            payment.dateText.localizedCaseInsensitiveContains(query)
                || String(format: "%.0f", payment.amount).contains(query)
                || notes.note(for: invoiceNumber(for: payment))
                    .localizedCaseInsensitiveContains(query)
        }
    }

    /// A plain-text summary of the year's charges, oldest first, with the total at the end.
    private var exportText: String {
        var lines = ["My plan — this year's charges"]

        for payment in payments.sorted(by: { $0.date < $1.date }) {
            lines.append("\(payment.dateText) · Monthly plan · \(String(format: "£%.0f", payment.amount))")
        }

        lines.append("")
        lines.append("Total spent: \(totalText) · \(payments.count == 1 ? "1 payment" : "\(payments.count) payments")")

        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    summaryCard

                    if !payments.isEmpty {
                        spendingCard
                    }

                    searchField

                    if payments.isEmpty {
                        emptyNote

                        VStack(spacing: 2) {
                            Text("No charges to share yet.")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(hex: "91A8C8"))

                            Text("No charges to save yet.")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(hex: "91A8C8"))
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    } else if filteredPayments.isEmpty {
                        noMatchesNote
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredPayments) { payment in
                                row(payment)
                            }
                        }
                    }

                    Text("Invoices are sent to your email.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "91A8C8"))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            writeExportFile()
        }
        .sheet(item: $selectedPayment) { payment in
            PlanReceiptView(
                dateText: payment.dateText,
                amount: payment.amount,
                billingPeriod: "Monthly",
                invoiceNumber: invoiceNumber(for: payment),
                paidWith: paidWithText,
                vatNumber: vatNumber,
                notes: notes,
                stores: stores
            )
        }
    }

    private var paidWithText: String {
        cards.selectedCard?.label ?? "your saved card"
    }

    /// Writes the year's charges to a text file the share sheet can hand on.
    private func writeExportFile() {
        guard !payments.isEmpty else { return }

        let year = Calendar.current.component(.year, from: Date())
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("payments-\(year).txt")

        do {
            try exportText.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
        } catch {
            exportURL = nil
        }
    }

    private func invoiceNumber(for payment: PlanPayment) -> String {
        let parts = payment.id.split(separator: "-")
        guard parts.count == 2, let month = Int(parts[1]) else {
            return "FB-\(payment.id)"
        }
        return "FB-\(parts[0])-\(String(format: "%02d", month))"
    }

    private var header: some View {
        ZStack {
            VStack(spacing: 2) {
                Text("Payments")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text("THIS YEAR")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            HStack(spacing: 8) {
                GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                    .accessibilityLabel("Back")

                Spacer(minLength: 0)

                if payments.isEmpty {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.tertiaryText)
                        .frame(width: 42, height: 42)
                        .background {
                            Circle()
                                .fill(Color.white.opacity(0.04))
                                .overlay {
                                    Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                }
                        }
                        .accessibilityLabel("Nothing to share yet")
                } else {
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.primaryText.opacity(0.9))
                                .frame(width: 42, height: 42)
                        }
                        .buttonStyle(GlassButtonStyle(cornerRadius: 21))
                        .accessibilityLabel("Save this year's payments as a file")
                    }

                    ShareLink(item: exportText) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.primaryText.opacity(0.9))
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(GlassButtonStyle(cornerRadius: 21))
                    .accessibilityLabel("Share this year's payments")
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search payments", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search payments")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.tertiaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "10213C"), tintOpacity: 0.55, shadowed: false)
    }

    private var noMatchesNote: some View {
        Text("No charges match that search.")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(hex: "AFC2DF"))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: "0B1526", opacity: 0.9))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                    }
            }
    }

    /// One entry per month of the year so far, with that month's charges added up.
    private var monthlySpend: [MonthSpend] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())

        return (1...currentMonth).map { month in
            let total = payments
                .filter { calendar.component(.month, from: $0.date) == month }
                .reduce(0) { $0 + $1.amount }
            return MonthSpend(month: month, amount: total)
        }
    }

    private var activeSpendMonth: Int {
        selectedSpendMonth ?? Calendar.current.component(.month, from: Date())
    }

    private var selectedSpendTitle: String {
        guard let item = monthlySpend.first(where: { $0.month == activeSpendMonth }) else {
            return "No charges yet"
        }

        let name = Calendar.current.monthSymbols[item.month - 1]
        return "\(name) · \(String(format: "£%.0f", item.amount))"
    }

    private func barHeight(for item: MonthSpend) -> CGFloat {
        let maxAmount = monthlySpend.map(\.amount).max() ?? 0
        guard maxAmount > 0 else { return 6 }
        return max(6, 60 * item.amount / maxAmount)
    }

    private var spendingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Spending")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))

                Spacer(minLength: 0)

                Text(totalText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
            }

            Text(selectedSpendTitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.cyan)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(monthlySpend) { item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSpendMonth = item.month
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Capsule()
                                .fill(
                                    item.month == activeSpendMonth
                                        ? AnyShapeStyle(Theme.accent)
                                        : AnyShapeStyle(Color(hex: "2A3F63"))
                                )
                                .frame(height: barHeight(for: item))

                            Text(item.letter)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(
                                    item.month == activeSpendMonth
                                        ? Theme.cyan
                                        : Color(hex: "8FA3BF")
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        "\(Calendar.current.monthSymbols[item.month - 1]), \(String(format: "£%.0f", item.amount))"
                    )
                }
            }
            .frame(height: 86, alignment: .bottom)
        }
        .padding(14)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
    }

    private var summaryCard: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total spent")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(totalText)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)

                    Text(paymentsCountText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "8FA3BF"))
                }
            }

            Spacer(minLength: 0)

            Text("All paid")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
        }
        .padding(16)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.72)
    }

    private func row(_ payment: PlanPayment) -> some View {
        Button {
            selectedPayment = payment
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(payment.dateText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Monthly plan")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "£%.0f", payment.amount))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Paid")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Theme.cyan)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                }

                if notes.hasNote(for: invoiceNumber(for: payment)) {
                    Image(systemName: "pencil")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Theme.violet)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Theme.violet.opacity(0.16)))
                        .overlay {
                            Circle().strokeBorder(Theme.violet.opacity(0.3), lineWidth: 1)
                        }
                        .accessibilityLabel("Has a note")
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.tertiaryText)
                    .padding(.leading, 2)
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(payment.dateText), \(amountText), paid, monthly plan")
        .accessibilityHint("Opens the receipt")
    }

    private var emptyNote: some View {
        Text("No payments yet — this year's charges will appear here.")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(hex: "AFC2DF"))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
    }
}

#Preview {
    PaymentsView(cards: PaymentCardsStore(), notes: PaymentNotesStore())
}
