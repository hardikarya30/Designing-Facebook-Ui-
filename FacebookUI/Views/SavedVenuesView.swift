//
//  SavedVenuesView.swift
//  FacebookUI
//
//  The places worth going back to, with the events happening there.
//

import SwiftUI

private enum SavedVenuesSheet: Identifiable {
    case venue(Venue)
    case save

    var id: String {
        switch self {
        case .venue(let venue): return venue.id
        case .save: return "save"
        }
    }
}

private enum VenuesSort: String, CaseIterable, Identifiable {
    case closest = "Closest first"
    case alphabetical = "A–Z"
    case recentlySaved = "Recently saved"

    var id: String { rawValue }

    var title: String { rawValue }

    var toggled: VenuesSort {
        switch self {
        case .closest: return .alphabetical
        case .alphabetical: return .recentlySaved
        case .recentlySaved: return .closest
        }
    }
}

struct SavedVenuesView: View {
    let events: [SocialEvent]
    var onBack: () -> Void = {}

    @StateObject private var store = SavedVenuesStore()

    @State private var searchText = ""
    @State private var activeSheet: SavedVenuesSheet?
    @State private var isVenuesMapPresented = false
    @State private var isAddVenuePresented = false
    @State private var selectedSort: VenuesSort = .closest

    private var allVenues: [Venue] {
        let venues = store.venues

        switch selectedSort {
        case .closest:
            return venues.sorted {
                SampleVenues.distanceMiles(to: $0) < SampleVenues.distanceMiles(to: $1)
            }
        case .alphabetical:
            return venues.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .recentlySaved:
            // Saved ids are appended as venues are saved, so the last one is the newest.
            let order = store.savedIDs
            return venues.sorted {
                let first = order.firstIndex(of: $0.id) ?? 0
                let second = order.firstIndex(of: $1.id) ?? 0
                return first > second
            }
        }
    }

    private var visibleVenues: [Venue] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allVenues }

        return allVenues.filter { venue in
            venue.name.localizedCaseInsensitiveContains(query)
                || venue.area.localizedCaseInsensitiveContains(query)
                || venue.address.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    searchField

                    if !store.venues.isEmpty {
                        countRow
                    }

                    if visibleVenues.isEmpty {
                        emptyState
                            .padding(.top, 4)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(visibleVenues) { venue in
                                venueRow(venue)
                            }
                        }
                        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: selectedSort)
                    }

                    Color.clear.frame(height: 96)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footer
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .venue(let venue):
                VenueDetailSheet(store: store, venue: venue, events: upcomingEvents(at: venue))
            case .save:
                SaveVenueSheet(store: store)
            }
        }
        .fullScreenCover(isPresented: $isVenuesMapPresented) {
            VenuesMapView(
                store: store,
                events: events,
                onBack: { isVenuesMapPresented = false }
            )
        }
        .fullScreenCover(isPresented: $isAddVenuePresented) {
            AddVenueView(store: store, onBack: { isAddVenuePresented = false })
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            GlassIconButton(systemName: "arrow.left", size: 42, action: onBack)
                .accessibilityLabel("Back to my address")

            VStack(alignment: .leading, spacing: 3) {
                Text("Saved venues")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .accessibilityAddTraits(.isHeader)

                Text("PLACES WORTH A RETURN")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(3.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)

            GlassIconButton(systemName: "plus", size: 38) {
                isAddVenuePresented = true
            }
            .accessibilityLabel("Add venue")

            GlassIconButton(systemName: "map.fill", size: 38) {
                isVenuesMapPresented = true
            }
            .accessibilityLabel("Venues map")
        }
        .padding(.bottom, 3)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search saved venues", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search saved venues")

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
        .padding(.horizontal, 15)
        .frame(height: 48)
        .glassSurface(cornerRadius: 25, tint: Color(hex: "1B355B"), tintOpacity: 0.56)
    }

    private var countRow: some View {
        HStack(spacing: 9) {
            Text("\(store.venues.count) SAVED VENUES")
                .font(.system(size: 9, weight: .bold))
                .tracking(1.3)
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.cyan.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.26), lineWidth: 1))

            Spacer(minLength: 0)

            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    selectedSort = selectedSort.toggled
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 9, weight: .bold))
                    Text(selectedSort.title)
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(Capsule().fill(Color(hex: "10213A", opacity: 0.9)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.28), lineWidth: 1))
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sort saved venues")
            .accessibilityValue(selectedSort.title)
        }
    }

    private func venueRow(_ venue: Venue) -> some View {
        HStack(spacing: 10) {
            Button {
                activeSheet = .venue(venue)
            } label: {
                HStack(spacing: 12) {
                    VenueArtwork(venue: venue)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(venue.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.primaryText)
                                .lineLimit(1)

                            if store.isVisited(venue) {
                                Text("Visited")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(Theme.cyan)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                            }

                            if store.isReminded(venue) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Theme.cyan)
                                    .accessibilityLabel("Reminder set")
                            }

                            Spacer(minLength: 0)
                        }

                        Text(venue.area)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "AFC2DF"))
                            .lineLimit(1)

                        Text(eventCountLabel(for: venue))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Theme.cyan)
                    }

                    Spacer(minLength: 6)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(distanceLabel(to: venue))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.primaryText)
                            .fixedSize()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Theme.tertiaryText)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(venue.name), \(venue.area), \(distanceLabel(to: venue))")

            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    store.remove(venue)
                }
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.13)))
                    .overlay(Circle().strokeBorder(Theme.cyan.opacity(0.28), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(venue.name) from saved venues")
        }
        .padding(10)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.66)
    }

    private var emptyState: some View {
        VStack(spacing: 11) {
            Image(systemName: searchText.isEmpty ? "bookmark" : "magnifyingglass")
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))

            Text(searchText.isEmpty ? "No saved venues yet" : "No venues found")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(searchText.isEmpty
                 ? "Tap Save a venue to keep a place you love."
                 : "Try another venue name or area.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .glassSurface(cornerRadius: 24, tint: Color(hex: "142846"), tintOpacity: 0.62)
    }

    private var footer: some View {
        Button {
            activeSheet = .save
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                Text("Save a venue")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Theme.primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .glassSurface(cornerRadius: 25, tint: Color(hex: "10213A"), tintOpacity: 0.85)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background {
            LinearGradient(
                colors: [Theme.midnight.opacity(0), Theme.midnight.opacity(0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
        .accessibilityLabel("Save a venue")
    }

    private func distanceLabel(to venue: Venue) -> String {
        String(format: "%.1f mi", SampleVenues.distanceMiles(to: venue))
    }

    private func upcomingEvents(at venue: Venue) -> [SocialEvent] {
        let now = Date()
        return events
            .filter { event in
                event.endDate >= now
                    && venue.matchTerms.contains { term in
                        event.location.localizedCaseInsensitiveContains(term)
                    }
            }
            .sorted { $0.date < $1.date }
    }

    private func eventCountLabel(for venue: Venue) -> String {
        let count = upcomingEvents(at: venue).count
        return count == 1 ? "1 upcoming event" : "\(count) upcoming events"
    }
}

// MARK: - Artwork

struct VenueArtwork: View {
    let venue: Venue

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: venue.colors.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(Color.white.opacity(0.13))
                    .frame(width: proxy.size.height * 1.2, height: proxy.size.height * 1.2)
                    .offset(x: proxy.size.width * 0.3, y: -proxy.size.height * 0.55)

                Image(systemName: venue.symbol)
                    .font(.system(size: proxy.size.height * 0.4, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.white.opacity(0.9))
            }
        }
    }
}

// MARK: - Venue details

struct VenueDetailSheet: View {
    @ObservedObject var store: SavedVenuesStore
    let venue: Venue
    let events: [SocialEvent]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var distanceText: String {
        String(format: "%.1f mi from home", SampleVenues.distanceMiles(to: venue))
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    hero
                    identity
                    addressCard
                    beenHereButton
                    eventsSection

                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                directionsButton
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            VenueArtwork(venue: venue)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            GlassIconButton(systemName: "xmark", size: 36) {
                dismiss()
            }
            .accessibilityLabel("Close venue")
            .padding(10)
        }
    }

    private var identity: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(venue.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10, weight: .semibold))
                    Text(venue.area)
                        .lineLimit(1)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
            }

            Spacer(minLength: 6)

            Text(distanceText)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Theme.cyan.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.26), lineWidth: 1))
                .fixedSize()
        }
    }

    private var addressCard: some View {
        HStack(spacing: 11) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text("ADDRESS")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.3)
                    .foregroundStyle(Color(hex: "91A8C8"))

                Text(venue.address)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.66)
    }

    private var beenHereButton: some View {
        let visited = store.isVisited(venue)
        let reminded = store.isReminded(venue)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        store.toggleVisited(venue)
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: visited ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Been here")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(visited ? Theme.cyan : Theme.primaryText.opacity(0.85))
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .glassSurface(
                        cornerRadius: 22,
                        tint: visited ? Theme.cyan : Theme.deepBlue,
                        tintOpacity: visited ? 0.24 : 0.5,
                        shadowed: false
                    )
                    .overlay(
                        Capsule().strokeBorder(
                            visited ? Theme.cyan.opacity(0.45) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                    )
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(visited ? "Visited. Remove mark" : "Mark as visited")
                .accessibilityValue(visited ? "Been here" : "Not visited")

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        store.toggleReminder(venue)
                    }
                } label: {
                    Image(systemName: reminded ? "bell.fill" : "bell")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(reminded ? Theme.cyan : Theme.primaryText.opacity(0.85))
                        .frame(width: 44, height: 44)
                        .glassSurface(
                            cornerRadius: 22,
                            tint: reminded ? Theme.cyan : Theme.deepBlue,
                            tintOpacity: reminded ? 0.24 : 0.5,
                            shadowed: false
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                reminded ? Theme.cyan.opacity(0.45) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(reminded ? "Turn off reminder" : "Remind me about the next event here")
            }

            if reminded {
                Text(nextEventLine)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: reminded)
    }

    private var nextEventLine: String {
        guard let next = events.first else {
            return "No upcoming events here yet."
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "EEE d MMM · h:mm a"
        return "Next event: \(formatter.string(from: next.date))"
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Events here")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                Spacer(minLength: 0)

                Text(events.isEmpty ? "Nothing coming up" : eventCountLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
            }

            if events.isEmpty {
                Text("No events here yet — check back soon.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .glassSurface(cornerRadius: 16, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
            } else {
                VStack(spacing: 8) {
                    ForEach(events) { event in
                        eventRow(event)
                    }
                }
            }
        }
    }

    private var eventCountLabel: String {
        events.count == 1 ? "1 event" : "\(events.count) events"
    }

    private func eventRow(_ event: SocialEvent) -> some View {
        HStack(spacing: 10) {
            VStack(spacing: 0) {
                Text(event.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(Theme.cyan)
                Text(event.date.formatted(.dateTime.day()))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 40, height: 44)
            .background(Color(hex: "0B1B31"), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(dateText(for: event))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(9)
        .glassSurface(cornerRadius: 16, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
    }

    private func dateText(for event: SocialEvent) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "EEE d MMM · h:mm a"
        return formatter.string(from: event.date)
    }

    private var directionsButton: some View {
        Button(action: openDirections) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.system(size: 13, weight: .semibold))
                Text("Directions")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Theme.midnight)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Capsule().fill(Theme.accent))
            .shadow(color: Theme.cyan.opacity(0.32), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background {
            LinearGradient(
                colors: [Theme.midnight.opacity(0), Theme.midnight.opacity(0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
        .accessibilityLabel("Get directions to \(venue.name)")
    }

    private func openDirections() {
        var components = URLComponents(string: "https://www.google.com/maps/dir/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: venue.address)
        ]
        guard let url = components?.url else { return }
        openURL(url)
    }
}

// MARK: - Save a venue

private struct SaveVenueSheet: View {
    @ObservedObject var store: SavedVenuesStore

    @Environment(\.dismiss) private var dismiss

    private var venues: [Venue] {
        SampleVenues.all.sorted {
            SampleVenues.distanceMiles(to: $0) < SampleVenues.distanceMiles(to: $1)
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    header

                    ForEach(venues) { venue in
                        row(venue)
                    }

                    Color.clear.frame(height: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Save a venue")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)

                Text("Places from your events, closest first")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "A9BCD8"))
            }

            Spacer(minLength: 0)

            GlassIconButton(systemName: "xmark", size: 36) {
                dismiss()
            }
            .accessibilityLabel("Close")
        }
    }

    private func row(_ venue: Venue) -> some View {
        let saved = store.isSaved(venue)

        return Button {
            guard !saved else { return }
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                store.save(venue)
            }
            dismiss()
        } label: {
            HStack(spacing: 12) {
                VenueArtwork(venue: venue)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(venue.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)

                    Text(venue.area)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                        .lineLimit(1)
                }

                Spacer(minLength: 6)

                Text(String(format: "%.1f mi", SampleVenues.distanceMiles(to: venue)))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .fixedSize()

                Image(systemName: saved ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(saved ? Theme.cyan : Theme.tertiaryText)
            }
            .padding(10)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
            .opacity(saved ? 0.58 : 1)
        }
        .buttonStyle(.plain)
        .disabled(saved)
        .accessibilityLabel(saved ? "\(venue.name) is already saved" : "Save \(venue.name)")
    }
}

#Preview {
    SavedVenuesView(events: SampleEvents.events)
}
