//
//  EventAttendeesSheet.swift
//  FacebookUI
//
//  Everyone going to an event, with a search field and going/interested filters.
//

import SwiftUI

struct EventAttendeesSheet: View {
    let event: SocialEvent

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var filter: AttendeeFilter = .all

    private enum AttendeeFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case going = "Going"
        case interested = "Interested"

        var id: String { rawValue }
    }

    private var filteredAttendees: [EventAttendee] {
        var people = event.attendees
        switch filter {
        case .all:
            break
        case .going:
            people = people.filter { !$0.isInterested }
        case .interested:
            people = people.filter(\.isInterested)
        }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return people }
        return people.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || $0.shared.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var showsMoreFooter: Bool {
        filter == .all
            && query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && event.extraAttendees > 0
            && !filteredAttendees.isEmpty
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header
                searchField
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                filters
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if filteredAttendees.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(filteredAttendees.enumerated()), id: \.element.id) { index, attendee in
                                    attendeeRow(attendee)

                                    if index < filteredAttendees.count - 1 {
                                        Rectangle()
                                            .fill(Theme.hairline)
                                            .frame(height: 1)
                                            .padding(.leading, 70)
                                    }
                                }
                            }
                            .glassSurface(cornerRadius: Theme.Radius.card)
                        }

                        if showsMoreFooter {
                            Text("and \(event.extraAttendees) others are going")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.tertiaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }

                        Color.clear.frame(height: 22)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Going")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .accessibilityAddTraits(.isHeader)

                Text("\(event.attendeeCount) people going")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
            }

            Spacer(minLength: 8)

            GlassIconButton(systemName: "xmark", size: 36) {
                dismiss()
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search guests", text: $query)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search guests")

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 46)
        .glassSurface(cornerRadius: 23, tint: Color(hex: "1B355B"), tintOpacity: 0.55, shadowed: false)
    }

    private var filters: some View {
        HStack(spacing: 4) {
            ForEach(AttendeeFilter.allCases) { option in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                        filter = option
                    }
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(filter == option ? .white : Color(hex: "AFC2DF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background {
                            if filter == option {
                                Capsule()
                                    .fill(Theme.accent)
                                    .shadow(color: Theme.cyan.opacity(0.4), radius: 7)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(filter == option ? .isSelected : [])
            }
        }
        .padding(4)
        .glassSurface(cornerRadius: 23, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
    }

    private func attendeeRow(_ attendee: EventAttendee) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: attendee.initials,
                palette: attendee.palette,
                size: 42,
                imageName: nil
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(attendee.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(attendee.shared)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            tag(attendee.isInterested)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(attendee.name), \(attendee.isInterested ? "interested" : "going"). \(attendee.shared)"
        )
    }

    private func tag(_ isInterested: Bool) -> some View {
        let tint = isInterested ? Theme.violet : Theme.cyan

        return Text(isInterested ? "Interested" : "Going")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(tint.opacity(0.14)))
            .overlay(Capsule().strokeBorder(tint.opacity(0.32), lineWidth: 1))
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Theme.cyan)

            Text("No guests match this search")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Try another name or a different filter.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.5, shadowed: false)
    }
}

#Preview {
    EventAttendeesSheet(event: SampleEvents.events[0])
}
