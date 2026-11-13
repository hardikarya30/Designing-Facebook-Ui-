//
//  PlanHistoryView.swift
//  FacebookUI
//
//  This year's plan story: when it started, every charge and every change.
//

import SwiftUI

struct PlanHistoryView: View {
    @ObservedObject var store: PlanHistoryStore

    var onBack: () -> Void = {}

    private struct Entry: Identifiable {
        enum Kind {
            case start
            case payment
            case pause
            case resume
            case change
        }

        let id: String
        let date: Date
        let kind: Kind
        let title: String
        let detail: String
        let tag: String?
    }

    private struct MonthSection: Identifiable {
        let id: String
        let title: String
        let entries: [Entry]
    }

    private var entries: [Entry] {
        var items: [Entry] = []
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        if let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) {
            items.append(Entry(
                id: "start-\(year)",
                date: start,
                kind: .start,
                title: "Plan started",
                detail: "\(dayText(start)) · £250 / month · 30% & 50% off",
                tag: nil
            ))
        }

        for month in 1...currentMonth {
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
                continue
            }
            items.append(Entry(
                id: "payment-\(year)-\(month)",
                date: date,
                kind: .payment,
                title: "Monthly payment",
                detail: "\(dayText(date)) · £250 · including all files",
                tag: "Paid"
            ))
        }

        for record in store.records where calendar.component(.year, from: record.date) == year {
            items.append(Entry(
                id: record.id,
                date: record.date,
                kind: kind(for: record.kind),
                title: title(for: record.kind),
                detail: "\(dayText(record.date)) · \(record.detail)",
                tag: record.kind == .resume ? "Resumed" : nil
            ))
        }

        return items.sorted { $0.date > $1.date }
    }

    private var sections: [MonthSection] {
        let grouped = Dictionary(grouping: entries) { entry -> String in
            let parts = Calendar.current.dateComponents([.year, .month], from: entry.date)
            return "\(parts.year ?? 0)-\(parts.month ?? 0)"
        }

        return grouped
            .map { key, items in
                MonthSection(
                    id: key,
                    title: monthTitle(items[0].date),
                    entries: items.sorted { $0.date > $1.date }
                )
            }
            .sorted { lhs, rhs in
                (lhs.entries.first?.date ?? .distantPast) > (rhs.entries.first?.date ?? .distantPast)
            }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    if entries.isEmpty {
                        emptyNote
                    } else {
                        ForEach(sections) { section in
                            Text(section.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(hex: "AFC2DF"))
                                .padding(.leading, 4)

                            VStack(spacing: 8) {
                                ForEach(section.entries) { entry in
                                    row(entry)
                                }
                            }
                        }
                    }

                    Text("History is kept on this device.")
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

    private var header: some View {
        HStack(spacing: 14) {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 3) {
                Text("Plan history")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text("THIS YEAR")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)

            Text(entries.count == 1 ? "1 event" : "\(entries.count) events")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(Capsule().fill(Theme.cyan.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.28), lineWidth: 1))
                .contentTransition(.numericText())
                .accessibilityLabel("\(entries.count) plan events")
        }
    }

    private func row(_ entry: Entry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol(for: entry.kind))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint(for: entry.kind))
                .frame(width: 32, height: 32)
                .background(Circle().fill(tint(for: entry.kind).opacity(0.16)))
                .overlay {
                    Circle().strokeBorder(tint(for: entry.kind).opacity(0.3), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(entry.detail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 6)

            if let tag = entry.tag {
                Text(tag)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
            }
        }
        .padding(12)
        .glassSurface(cornerRadius: 16, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
    }

    private var emptyNote: some View {
        Text("Nothing yet — your plan's story starts with the first charge.")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(hex: "AFC2DF"))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
    }

    private func kind(for kind: PlanHistoryRecord.Kind) -> Entry.Kind {
        switch kind {
        case .pause: return .pause
        case .resume: return .resume
        case .change: return .change
        }
    }

    private func title(for kind: PlanHistoryRecord.Kind) -> String {
        switch kind {
        case .pause: return "Plan paused"
        case .resume: return "Plan resumed"
        case .change: return "Billing changed"
        }
    }

    private func symbol(for kind: Entry.Kind) -> String {
        switch kind {
        case .start: return "flag.fill"
        case .payment: return "sterlingsign.circle.fill"
        case .pause: return "pause.fill"
        case .resume: return "play.fill"
        case .change: return "slider.horizontal.3"
        }
    }

    private func tint(for kind: Entry.Kind) -> Color {
        switch kind {
        case .payment, .change: return Theme.violet
        case .pause, .resume, .start: return Theme.cyan
        }
    }

    private func dayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    PlanHistoryView(store: PlanHistoryStore())
}
