//
//  EventsView.swift
//  FacebookUI
//
//  Search nearby events and manage local RSVP responses.
//

import SwiftUI

private enum EventsSection: String, CaseIterable, Identifiable {
    case upcoming = "Upcoming"
    case invites = "Invites"
    case past = "Past"

    var id: String { rawValue }
}

private enum EventsDistanceFilter: Double, CaseIterable, Identifiable {
    case any = 0
    case two = 2
    case five = 5
    case ten = 10

    var id: Double { rawValue }

    var title: String {
        switch self {
        case .any: return "Any distance"
        case .two: return "Within 2 mi"
        case .five: return "Within 5 mi"
        case .ten: return "Within 10 mi"
        }
    }

    var symbol: String {
        switch self {
        case .any: return "globe.europe.africa.fill"
        case .two: return "figure.walk"
        case .five: return "bicycle"
        case .ten: return "car.fill"
        }
    }

    var miles: Int { Int(rawValue) }
}

private enum EventsSort: String, CaseIterable, Identifiable {
    case soonest = "Soonest"
    case nearest = "Nearest"

    var id: String { rawValue }

    var title: String { rawValue }

    var toggled: EventsSort {
        self == .soonest ? .nearest : .soonest
    }
}

struct EventsView: View {
    @ObservedObject var store: EventsStore
    var onBack: () -> Void = {}
    var accountName: String = "You"
    var messagesStore: MessagesStore = MessagesStore()
    var feedStore: FeedStore = FeedStore()
    var commentsStore: CommentsStore = CommentsStore()
    var savedStore: SavedPostsStore = SavedPostsStore()

    @State private var searchText = ""
    @State private var selectedSection: EventsSection = .upcoming
    @State private var selectedCategory: EventCategory?
    @State private var selectedDistance: EventsDistanceFilter = .any
    @State private var selectedSort: EventsSort = .soonest
    @State private var selectedEvent: SocialEvent?
    @State private var isCreatingEvent = false
    @State private var isSavedEventsPresented = false

    private var visibleEvents: [SocialEvent] {
        var events: [SocialEvent]

        switch selectedSection {
        case .upcoming:
            events = store.events.filter { !$0.isInvitation && $0.endDate >= Date() }
        case .invites:
            events = store.events.filter { $0.isInvitation && !store.isDeclined($0) }
        case .past:
            events = store.events
                .filter { $0.endDate < Date() }
                .sorted { $0.date > $1.date }
        }

        if let selectedCategory {
            events = events.filter { $0.category == selectedCategory }
        }

        // The radius only narrows Upcoming; invitations and past events are left alone.
        if selectedSection == .upcoming, selectedDistance != .any {
            events = events.filter { event in
                EventLocations.distanceMiles(to: event) <= selectedDistance.rawValue
            }
        }

        // Nearest only changes the order of Upcoming; the pinned event is pulled out first below.
        if selectedSection == .upcoming, selectedSort == .nearest {
            events.sort {
                EventLocations.distanceMiles(to: $0) < EventLocations.distanceMiles(to: $1)
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return events }
        return events.filter { event in
            event.title.localizedCaseInsensitiveContains(query)
                || event.location.localizedCaseInsensitiveContains(query)
                || (event.inviter?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            Group {
                if isSavedEventsPresented {
                    SavedEventsView(
                        store: store,
                        onBack: {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                                isSavedEventsPresented = false
                            }
                        }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else if let event = selectedEvent {
                    EventDetailsView(
                        event: event,
                        response: store.response(for: event),
                        onBack: {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                                selectedEvent = nil
                            }
                        },
                        onResponse: { store.setResponse($0, for: event) },
                        isReminded: store.isReminded(event),
                        reminderDate: store.reminderDate(for: event),
                        onToggleReminder: { store.toggleReminder(event) },
                        authorName: accountName,
                        isPinned: store.isPinned(event),
                        onTogglePin: { store.togglePin(event) },
                        rating: store.rating(for: event),
                        onRate: { store.setRating($0, for: event) },
                        messagesStore: messagesStore,
                        feedStore: feedStore,
                        commentsStore: commentsStore,
                        savedStore: savedStore
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    eventList
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $isCreatingEvent) {
            CreateEventView(
                hostName: accountName,
                onBack: { isCreatingEvent = false },
                onCreate: { event in
                    store.addEvent(event)
                    selectedSection = .upcoming
                    selectedCategory = nil
                    searchText = ""
                    isCreatingEvent = false
                }
            )
        }
    }

    private var eventList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                header
                searchField
                sectionPicker
                categoryChips

                if selectedSection == .upcoming {
                    distanceChips

                    if selectedDistance != .any {
                        activeRadiusBanner
                    }
                }

                if visibleEvents.isEmpty {
                    emptyState
                        .padding(.top, 20)
                } else {
                    LazyVStack(spacing: 14) {
                        if let pinned = pinnedEvent {
                            sectionLabel("Pinned", isPinned: true)

                            eventCard(pinned, isPinned: true)

                            if !otherEvents.isEmpty {
                                sectionLabel(selectedSection.rawValue, isPinned: false)
                                    .padding(.top, 3)
                            }
                        }

                        ForEach(otherEvents) { event in
                            eventCard(event, isPinned: false)
                        }
                    }
                    .padding(.top, 1)
                }

                Color.clear.frame(height: 104)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var pinnedEvent: SocialEvent? {
        guard selectedSection == .upcoming, let pinnedID = store.pinnedID else { return nil }
        return visibleEvents.first { $0.id == pinnedID }
    }

    private var otherEvents: [SocialEvent] {
        guard let pinnedEvent else { return visibleEvents }
        return visibleEvents.filter { $0.id != pinnedEvent.id }
    }

    private func sectionLabel(_ text: String, isPinned: Bool) -> some View {
        HStack(spacing: 6) {
            if isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9, weight: .bold))
            }

            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
        }
        .foregroundStyle(isPinned ? Theme.cyan : Theme.tertiaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 4)
    }

    private func eventCard(_ event: SocialEvent, isPinned: Bool) -> some View {
        EventCard(
            event: event,
            response: store.response(for: event),
            isSaved: store.isSaved(event),
            onToggleSaved: { store.toggleSaved(event) },
            onOpen: {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    selectedEvent = event
                }
            },
            onResponse: { store.setResponse($0, for: event) },
            onDecline: { store.decline(event) },
            isReminded: store.isReminded(event),
            isPinned: isPinned,
            isPast: event.endDate < Date(),
            onTogglePin: {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    store.togglePin(event)
                }
            }
        )
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("Events")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)
                Text("Find your next favourite moment")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "A8B9D4"))
            }

            Spacer(minLength: 0)

            HStack(spacing: 7) {
                GlassIconButton(systemName: "bookmark", size: 38) {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                        isSavedEventsPresented = true
                    }
                }
                .accessibilityLabel("Saved events")

                GlassIconButton(systemName: "plus", size: 38) {
                    isCreatingEvent = true
                }
                .accessibilityLabel("Create event")
            }
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 1)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search events or places", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search events")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .glassSurface(cornerRadius: 27, tint: Color(hex: "1B355B"), tintOpacity: 0.55)
    }

    private var sectionPicker: some View {
        HStack(spacing: 4) {
            ForEach(EventsSection.allCases) { section in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedSection = section
                    }
                } label: {
                    HStack(spacing: 7) {
                        Text(section.rawValue)
                        if section == .invites, store.invitationCount > 0 {
                            Text("\(store.invitationCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(selectedSection == section ? Theme.deepBlue : Theme.cyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(selectedSection == section ? Color.white.opacity(0.76) : Theme.cyan.opacity(0.14)))
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedSection == section ? .white : Color(hex: "AFC2DF"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background {
                        if selectedSection == section {
                            Capsule()
                                .fill(Theme.accent)
                                .shadow(color: Theme.cyan.opacity(0.45), radius: 8)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedSection == section ? .isSelected : [])
            }
        }
        .padding(5)
        .glassSurface(cornerRadius: 28, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(
                    title: "All",
                    symbol: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(EventCategory.allCases) { category in
                    categoryChip(
                        title: category.title,
                        symbol: category.symbol,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -16)
    }

    private var distanceChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EventsDistanceFilter.allCases) { filter in
                    distanceChip(filter)
                }

                sortChip
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -16)
    }

    private func distanceChip(_ filter: EventsDistanceFilter) -> some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selectedDistance = filter
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.symbol)
                    .font(.system(size: 11, weight: .semibold))
                Text(filter.title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(selectedDistance == filter ? Color.white : Color(hex: "A9BCD8"))
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background {
                if selectedDistance == filter {
                    Capsule()
                        .fill(Theme.accent)
                        .shadow(color: Theme.cyan.opacity(0.35), radius: 7)
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                }
            }
            .overlay(
                Capsule().strokeBorder(
                    selectedDistance == filter ? Color.white.opacity(0.16) : Color.white.opacity(0.09),
                    lineWidth: 1
                )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedDistance == filter ? .isSelected : [])
        .accessibilityLabel(filter.title)
    }

    private var sortChip: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selectedSort = selectedSort.toggled
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 10, weight: .semibold))
                Text(selectedSort.title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(Theme.cyan)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Capsule().fill(Color(hex: "10213A", opacity: 0.92)))
            .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Sort events")
        .accessibilityValue(selectedSort.title)
    }

    private var activeRadiusBanner: some View {
        HStack(spacing: 7) {
            Image(systemName: "location.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.cyan)

            Text("Showing events within \(selectedDistance.miles) miles of home")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .frame(height: 30)
        .background(Capsule().fill(Theme.cyan.opacity(0.1)))
        .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.22), lineWidth: 1))
        .accessibilityElement(children: .combine)
    }

    private func categoryChip(
        title: String,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                action()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.white : Color(hex: "C2D1E6"))
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.accent)
                        .shadow(color: Theme.cyan.opacity(0.4), radius: 8)
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.055))
                }
            }
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.white.opacity(0.16) : Color.white.opacity(0.1),
                    lineWidth: 1
                )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(title) events")
    }

    private var emptySymbol: String {
        if !searchText.isEmpty { return "magnifyingglass" }
        if let selectedCategory { return selectedCategory.symbol }
        if selectedSection == .past { return "clock.arrow.circlepath" }
        return "calendar.badge.clock"
    }

    private var emptyTitle: String {
        if !searchText.isEmpty { return "No events found" }
        if selectedSection == .upcoming, selectedDistance != .any {
            return "No events within \(selectedDistance.miles) miles"
        }
        if let selectedCategory { return "No \(selectedCategory.title) events" }
        if selectedSection == .past { return "Nothing here yet" }
        return "No events here yet"
    }

    private var emptyMessage: String {
        if !searchText.isEmpty { return "Try another event name or location." }
        if selectedSection == .upcoming, selectedDistance != .any {
            return "Try a wider radius, or choose Any distance to see every event."
        }
        if selectedCategory != nil { return "Try another category, or choose All to see every event." }
        if selectedSection == .past { return "Events you attend will appear once they're over." }
        return "When friends invite you, their events will appear here."
    }

    private var emptyState: some View {
        VStack(spacing: 13) {
            Image(systemName: emptySymbol)
                .font(.system(size: 29, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 68, height: 68)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))

            Text(emptyTitle)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(emptyMessage)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .glassSurface(cornerRadius: 24, tint: Color(hex: "142846"), tintOpacity: 0.54)
    }
}

private struct EventCard: View {
    let event: SocialEvent
    let response: EventRSVP?
    let isSaved: Bool
    let onToggleSaved: () -> Void
    let onOpen: () -> Void
    let onResponse: (EventRSVP?) -> Void
    let onDecline: () -> Void
    let isReminded: Bool
    let isPinned: Bool
    let isPast: Bool
    let onTogglePin: () -> Void

    var body: some View {
        VStack(spacing: 9) {
            ZStack(alignment: .topTrailing) {
                Button(action: onOpen) {
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack(alignment: .topLeading) {
                            EventsArtwork(style: event.artwork)
                                .frame(height: 142)
                                .saturation(isPast ? 0.4 : 1)
                                .opacity(isPast ? 0.86 : 1)

                            VStack(spacing: 1) {
                                Text(event.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(Theme.cyan)
                                Text(event.date.formatted(.dateTime.day()))
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 52, height: 56)
                            .background(Color(hex: "08101E", opacity: 0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
                            .padding(12)

                            if event.isInvitation {
                                Text("INVITED")
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1.1)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "111A2D", opacity: 0.78), in: Capsule())
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .padding(12)
                            }

                            if isPinned {
                                HStack(spacing: 4) {
                                    Image(systemName: "pin.fill")
                                        .font(.system(size: 8, weight: .bold))
                                    Text("PINNED")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1.1)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(hex: "111A2D", opacity: 0.78), in: Capsule())
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                .padding(12)
                                .accessibilityLabel("Pinned event")
                            }

                            if isPast, response == .going {
                                Text("YOU WENT")
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1.1)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "111A2D", opacity: 0.78), in: Capsule())
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                    .padding(12)
                                    .accessibilityLabel("You went to this event")
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

                        VStack(alignment: .leading, spacing: 8) {
                            if let inviter = event.inviter, event.isInvitation {
                                Text("Invited by \(inviter)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Theme.violet)
                            }

                            Text(event.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(Theme.cyan)
                                Text(event.location)
                                    .foregroundStyle(Color(hex: "B8C8E0"))
                                    .lineLimit(1)
                            }
                            .font(.system(size: 12, weight: .medium))

                            if !isPast, !event.isInvitation {
                                HStack(spacing: 6) {
                                    Image(systemName: "location.fill")
                                    Text(EventLocations.distanceLabel(for: event))
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(hex: "98ACC8"))
                                .accessibilityLabel(EventLocations.distanceLabel(for: event))
                            }

                            HStack(spacing: 7) {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(Color(hex: "AEBFE0"))
                                Text("\(event.attendeeCount) people \(isPast ? "went" : "going")")
                                    .foregroundStyle(Color(hex: "AEBFE0"))
                            }
                            .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 3)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View details for \(event.title)")

                HStack(spacing: 8) {
                    if isReminded {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.cyan)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color(hex: "10213D", opacity: 0.82)))
                            .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
                            .accessibilityLabel("Reminder set")
                    }

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.76)) {
                            onToggleSaved()
                        }
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isSaved ? Theme.cyan : Color.white)
                            .frame(width: 40, height: 40)
                            .glassSurface(cornerRadius: 20, tint: Color(hex: "10213D"), tintOpacity: 0.78)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSaved ? "Remove \(event.title) from saved events" : "Save \(event.title)")

                    Menu {
                        Button {
                            onTogglePin()
                        } label: {
                            Label(
                                isPinned ? "Unpin from Upcoming" : "Pin to top",
                                systemImage: isPinned ? "pin.slash" : "pin"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(width: 40, height: 40)
                            .glassSurface(cornerRadius: 20, tint: Color(hex: "10213D"), tintOpacity: 0.78)
                    }
                    .accessibilityLabel("Event options")
                    .opacity(isPast ? 0 : 1)
                    .frame(width: isPast ? 0 : 40, height: 40)
                    .clipped()
                }
                .padding(10)
            }

            HStack(spacing: 9) {
                ForEach(EventRSVP.allCases) { choice in
                    rsvpButton(choice)
                }
                shareButton
            }
            .opacity(isPast ? 0 : 1)
            .frame(height: isPast ? 0 : nil)
            .clipped()

            if event.isInvitation, !isPast {
                declineButton
            }
        }
        .padding(10)
        .glassSurface(cornerRadius: 24, tint: Color(hex: "142846"), tintOpacity: 0.68)
    }

    private var declineButton: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                onDecline()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                Text("Decline")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(Color(hex: "FFAFC3"))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Capsule().fill(Theme.rose.opacity(0.13)))
            .overlay(Capsule().strokeBorder(Theme.rose.opacity(0.28), lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Decline the invitation to \(event.title)")
    }

    private var shareButton: some View {
        ShareLink(item: shareText) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "D5E1F4"))
                .frame(width: 42, height: 39)
                .glassSurface(cornerRadius: 20, tint: Color(hex: "10213D"), tintOpacity: 0.78)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share \(event.title)")
    }

    private var shareText: String {
        let date = event.date.formatted(date: .long, time: .shortened)
        return "\(event.title)\n\(date)\n\(event.location)\nfacebookui://events/\(event.id)"
    }

    private func rsvpButton(_ choice: EventRSVP) -> some View {
        let isSelected = response == choice
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                onResponse(isSelected ? nil : choice)
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: choice.symbol)
                    .font(.system(size: 12, weight: .bold))
                Text(choice.title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.white : Color(hex: "D5E1F4"))
            .frame(maxWidth: .infinity)
            .frame(height: 39)
            .background {
                if isSelected {
                    Capsule().fill(choice == .going ? Theme.accent : LinearGradient(colors: [Theme.violet, Color(hex: "7364C5")], startPoint: .leading, endPoint: .trailing))
                } else {
                    Capsule().fill(Color.white.opacity(0.055))
                }
            }
            .overlay(Capsule().strokeBorder(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(choice.title) for \(event.title)")
    }
}

#Preview {
    EventsView(store: EventsStore())
}
