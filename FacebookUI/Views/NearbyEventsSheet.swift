//
//  NearbyEventsSheet.swift
//  FacebookUI
//
//  The events close to your saved address, with the ones you can walk or hop on a bus to.
//

import MapKit
import SwiftUI

/// The stores an event opened from elsewhere in the app needs, passed down from RootView.
struct EventStores {
    let events: EventsStore
    let messages: MessagesStore
    let feed: FeedStore
    let comments: CommentsStore
    let saved: SavedPostsStore
}

private enum NearbyRadius: Double, CaseIterable, Identifiable {
    case two = 2
    case five = 5
    case ten = 10

    var id: Double { rawValue }

    var miles: Int { Int(rawValue) }

    var title: String { "\(miles) miles" }
}

struct NearbyEventsSheet: View {
    let homeCoordinate: CLLocationCoordinate2D
    let areaLabel: String
    let postcode: String
    let events: [SocialEvent]

    var stores: EventStores? = nil
    var onOpenEvents: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    /// Remembered across launches, so the sheet opens at the radius you last chose.
    @AppStorage("events.nearbyRadius") private var radiusMiles: Double = 5

    @State private var openedEvent: SocialEvent?
    @State private var isAllEventsPresented = false
    @State private var camera: MapCameraPosition = .automatic

    @StateObject private var fallbackEvents = EventsStore()
    @StateObject private var fallbackMessages = MessagesStore()
    @StateObject private var fallbackFeed = FeedStore()
    @StateObject private var fallbackComments = CommentsStore()
    @StateObject private var fallbackSaved = SavedPostsStore()

    private var selectedRadius: NearbyRadius {
        NearbyRadius(rawValue: radiusMiles) ?? .five
    }

    private var resolvedStores: EventStores {
        stores ?? EventStores(
            events: fallbackEvents,
            messages: fallbackMessages,
            feed: fallbackFeed,
            comments: fallbackComments,
            saved: fallbackSaved
        )
    }

    private var nearby: [NearbyEvent] {
        EventLocations.nearbyEvents(
            from: events,
            home: homeCoordinate,
            withinMiles: selectedRadius.rawValue
        )
    }

    private var areaLine: String {
        let area = areaLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = postcode.trimmingCharacters(in: .whitespacesAndNewlines)

        if area.isEmpty && code.isEmpty { return "Events close to your address" }
        if code.isEmpty { return area }
        if area.isEmpty { return code }
        return "\(area) · \(code)"
    }

    /// A region that always holds the chosen radius around home.
    private var mapRegion: MKCoordinateRegion {
        let latitudeDelta = (selectedRadius.rawValue / 69.0) * 2 * 1.6
        let longitudeDelta = latitudeDelta / max(cos(homeCoordinate.latitude * .pi / 180), 0.2)

        return MKCoordinateRegion(
            center: homeCoordinate,
            span: MKCoordinateSpan(
                latitudeDelta: max(latitudeDelta, 0.015),
                longitudeDelta: max(longitudeDelta, 0.015)
            )
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    map
                    radiusPicker
                    sectionHeader
                    rows

                    Color.clear.frame(height: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footer
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .fullScreenCover(item: $openedEvent) { event in
            details(for: event)
        }
        .fullScreenCover(isPresented: $isAllEventsPresented) {
            EventsView(
                store: resolvedStores.events,
                onBack: { isAllEventsPresented = false },
                accountName: Author.me.name,
                messagesStore: resolvedStores.messages,
                feedStore: resolvedStores.feed,
                commentsStore: resolvedStores.comments,
                savedStore: resolvedStores.saved
            )
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Near me")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)

                Text(areaLine)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "A9BCD8"))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.white.opacity(0.08)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.14)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close nearby events")
        }
    }

    private var map: some View {
        Map(position: $camera) {
            Marker("Home", systemImage: "house.fill", coordinate: homeCoordinate)
                .tint(Theme.cyan)

            ForEach(nearby) { item in
                Marker(
                    item.event.title,
                    systemImage: item.event.category.symbol,
                    coordinate: EventLocations.coordinate(for: item.event)
                )
                .tint(Theme.violet)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
        .frame(height: 158)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        }
        .overlay(alignment: .bottomLeading) {
            HStack(spacing: 5) {
                Image(systemName: "location.fill")
                    .font(.system(size: 9, weight: .bold))
                Text("Your address")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color(hex: "08101E", opacity: 0.8), in: Capsule())
            .padding(10)
        }
        .accessibilityLabel("Map of events near \(areaLine)")
        .onAppear {
            camera = .region(mapRegion)
        }
        .onChange(of: radiusMiles) { _, _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                camera = .region(mapRegion)
            }
        }
    }

    private var radiusPicker: some View {
        HStack(spacing: 8) {
            ForEach(NearbyRadius.allCases) { radius in
                radiusPill(radius)
            }
        }
    }

    private func radiusPill(_ radius: NearbyRadius) -> some View {
        let isSelected = selectedRadius == radius

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                radiusMiles = radius.rawValue
            }
        } label: {
            Text(radius.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? Theme.cyan : Color(hex: "C2D1E6"))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .glassSurface(
                    cornerRadius: 17,
                    tint: isSelected ? Theme.cyan : Color(hex: "142846"),
                    tintOpacity: isSelected ? 0.22 : 0.4,
                    shadowed: false
                )
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? Theme.cyan.opacity(0.4) : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("Within \(radius.title)")
    }

    private var sectionHeader: some View {
        HStack(spacing: 9) {
            HStack(spacing: 5) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 10, weight: .bold))
                Text("Within \(selectedRadius.miles) miles")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(Theme.cyan)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Theme.cyan.opacity(0.13)))
            .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.28), lineWidth: 1))

            Text(countLabel)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))

            Spacer(minLength: 0)
        }
    }

    private var countLabel: String {
        nearby.count == 1 ? "1 event close by" : "\(nearby.count) events close by"
    }

    @ViewBuilder
    private var rows: some View {
        if nearby.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: 10) {
                ForEach(nearby) { item in
                    row(item)
                }
            }
        }
    }

    private func row(_ item: NearbyEvent) -> some View {
        Button {
            openedEvent = item.event
        } label: {
            HStack(spacing: 12) {
                EventsArtwork(style: item.event.artwork)
                    .frame(width: 56, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(dateLabel(for: item.event))
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(Theme.cyan)

                    Text(item.event.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 9, weight: .semibold))
                        Text(item.event.location)
                            .lineLimit(1)
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 6)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.distanceLabel)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .fixedSize()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Theme.tertiaryText)
                }
            }
            .padding(10)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.64, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.event.title), \(item.distanceLabel)")
    }

    private var emptyState: some View {
        VStack(spacing: 9) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 54, height: 54)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))

            Text("Nothing within \(selectedRadius.miles) miles")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text("Try a wider radius, or open the full events list for plans further out.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.62)
    }

    private var footer: some View {
        Button(action: showAllEvents) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .semibold))
                Text("See all events")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Theme.midnight)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Capsule().fill(Theme.accent))
            .shadow(color: Theme.cyan.opacity(0.3), radius: 16, y: 8)
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
        .accessibilityLabel("See all events")
    }

    private func showAllEvents() {
        if let onOpenEvents {
            dismiss()
            onOpenEvents()
        } else {
            isAllEventsPresented = true
        }
    }

    private func dateLabel(for event: SocialEvent) -> String {
        let day = DateFormatter()
        day.locale = Locale(identifier: "en_GB")
        day.dateFormat = "EEE d MMM"

        let time = DateFormatter()
        time.locale = Locale(identifier: "en_GB")
        time.dateFormat = "h:mm a"

        return "\(day.string(from: event.date).uppercased()) · \(time.string(from: event.date))"
    }

    private func details(for event: SocialEvent) -> some View {
        let stores = resolvedStores

        return EventDetailsView(
            event: event,
            response: stores.events.response(for: event),
            onBack: { openedEvent = nil },
            onResponse: { stores.events.setResponse($0, for: event) },
            isReminded: stores.events.isReminded(event),
            reminderDate: stores.events.reminderDate(for: event),
            onToggleReminder: { stores.events.toggleReminder(event) },
            authorName: Author.me.name,
            isPinned: stores.events.isPinned(event),
            onTogglePin: { stores.events.togglePin(event) },
            rating: stores.events.rating(for: event),
            onRate: { stores.events.setRating($0, for: event) },
            messagesStore: stores.messages,
            feedStore: stores.feed,
            commentsStore: stores.comments,
            savedStore: stores.saved
        )
    }
}

#Preview {
    NearbyEventsSheet(
        homeCoordinate: EventLocations.homeCoordinate,
        areaLabel: "Around North Cheam",
        postcode: "SM3 8JB",
        events: SampleEvents.events
    )
}
