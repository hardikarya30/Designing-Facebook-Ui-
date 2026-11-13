//
//  RemindersScreenView.swift
//  FacebookUI
//
//  Every reminder you have set, on events and on saved venues in one list.
//

import SwiftUI

struct RemindersScreenView: View {
    @ObservedObject var eventsStore: EventsStore
    @ObservedObject var venuesStore: SavedVenuesStore
    var onBack: () -> Void = {}

    @AppStorage("plan.renewalReminder") private var renewalReminder = false
    @AppStorage("plan.cancelled") private var isPlanCancelled = false
    @AppStorage("plan.yearly") private var isYearly = false
    @AppStorage("plan.paused") private var isPaused = false

    private var showsPlanReminder: Bool {
        renewalReminder && !isPlanCancelled
    }

    private var renewalDate: Date {
        let calendar = Calendar.current
        let component: Calendar.Component = isYearly ? .year : .month
        let base = calendar.date(byAdding: component, value: 1, to: Date()) ?? Date()
        if isPaused {
            return calendar.date(byAdding: .month, value: 1, to: base) ?? base
        }
        return base
    }

    private var renewalText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: renewalDate)
    }

    private var upcomingEventReminders: [SocialEvent] {
        let now = Date()
        return eventsStore.events
            .filter { eventsStore.remindedIDs.contains($0.id) && $0.endDate >= now }
            .sorted { $0.date < $1.date }
    }

    private var venueReminders: [Venue] {
        venuesStore.venues.filter { venuesStore.remindedIDs.contains($0.id) }
    }

    private var totalCount: Int {
        upcomingEventReminders.count + venueReminders.count + (showsPlanReminder ? 1 : 0)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    if totalCount == 0 {
                        emptyNote
                    } else {
                        if !upcomingEventReminders.isEmpty {
                            sectionTitle("Events")
                            VStack(spacing: 8) {
                                ForEach(upcomingEventReminders) { event in
                                    eventRow(event)
                                }
                            }
                        }

                        if !venueReminders.isEmpty {
                            sectionTitle("Venues")
                            VStack(spacing: 8) {
                                ForEach(venueReminders) { venue in
                                    venueRow(venue)
                                }
                            }
                        }

                        if showsPlanReminder {
                            sectionTitle("Plan")
                            VStack(spacing: 8) {
                                planRow
                            }
                        }
                    }

                    Text("Tap a bell to turn a reminder off.")
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
                Text("Your reminders")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text("EVENTS, VENUES & PLAN")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)

            Text("\(totalCount)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .frame(minWidth: 30)
                .frame(height: 28)
                .background(Capsule().fill(Theme.cyan.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.28), lineWidth: 1))
                .contentTransition(.numericText())
                .accessibilityLabel("\(totalCount) reminders set")
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color(hex: "AFC2DF"))
            .padding(.leading, 4)
    }

    private func eventRow(_ event: SocialEvent) -> some View {
        HStack(spacing: 12) {
            EventsArtwork(style: event.artwork)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(dayAndTime(for: event))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            bellButton(isReminded: true, label: "Turn off the reminder for \(event.title)") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    eventsStore.toggleReminder(event)
                }
            }
        }
        .padding(10)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
    }

    private func venueRow(_ venue: Venue) -> some View {
        HStack(spacing: 12) {
            VenueArtwork(venue: venue)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(venue.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(venueReminderLine(for: venue))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            bellButton(isReminded: true, label: "Turn off the reminder for \(venue.name)") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    venuesStore.toggleReminder(venue)
                }
            }
        }
        .padding(10)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
    }

    private var planRow: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "263B78"), Color(hex: "6B3B82")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text("Plan renewal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text("Renews \(renewalText)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            bellButton(isReminded: true, label: "Turn off the renewal reminder") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    renewalReminder = false
                }
            }
        }
        .padding(10)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
    }

    private func bellButton(isReminded: Bool, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: isReminded ? "bell.fill" : "bell")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isReminded ? Theme.cyan : Theme.tertiaryText)
                .frame(width: 36, height: 36)
                .background(Circle().fill(isReminded ? Theme.cyan.opacity(0.16) : Color.white.opacity(0.06)))
                .overlay {
                    Circle().strokeBorder(
                        isReminded ? Theme.cyan.opacity(0.3) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var emptyNote: some View {
        Text("No reminders yet — tap a bell on an event or venue to be nudged.")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(hex: "AFC2DF"))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
    }

    private func dayAndTime(for event: SocialEvent) -> String {
        let day = DateFormatter()
        day.locale = Locale(identifier: "en_GB")
        day.dateFormat = "EEE d MMM"

        let time = DateFormatter()
        time.locale = Locale(identifier: "en_GB")
        time.dateFormat = "h:mm a"

        return "\(day.string(from: event.date)) · \(time.string(from: event.date))"
    }

    private func venueReminderLine(for venue: Venue) -> String {
        let now = Date()
        let next = eventsStore.events
            .filter { event in
                event.endDate >= now && venue.matchTerms.contains { term in
                    event.location.localizedCaseInsensitiveContains(term)
                }
            }
            .sorted { $0.date < $1.date }
            .first

        guard let next else {
            return "No upcoming events here yet."
        }

        let day = DateFormatter()
        day.locale = Locale(identifier: "en_GB")
        day.dateFormat = "EEE d MMM"
        return "Next event \(day.string(from: next.date))"
    }
}

#Preview {
    RemindersScreenView(eventsStore: EventsStore(), venuesStore: SavedVenuesStore())
}
