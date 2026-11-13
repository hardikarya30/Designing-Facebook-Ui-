//
//  VenuesMapView.swift
//  FacebookUI
//
//  Every saved venue on one map, around your home.
//

import MapKit
import SwiftUI

struct VenuesMapView: View {
    @ObservedObject var store: SavedVenuesStore
    let events: [SocialEvent]
    var onBack: () -> Void = {}

    @State private var selectedVenueID: String?
    @State private var openedVenue: Venue?
    @State private var camera: MapCameraPosition = .automatic

    private var venues: [Venue] {
        store.venues.sorted {
            SampleVenues.distanceMiles(to: $0) < SampleVenues.distanceMiles(to: $1)
        }
    }

    private var selectedVenue: Venue? {
        guard let selectedVenueID else { return nil }
        return venues.first { $0.id == selectedVenueID }
    }

    private var mapRegion: MKCoordinateRegion {
        let points = [EventLocations.homeCoordinate] + venues.map { $0.coordinate }
        let latitudes = points.map { $0.latitude }
        let longitudes = points.map { $0.longitude }

        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else {
            return MKCoordinateRegion(
                center: EventLocations.homeCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.7, 0.02),
            longitudeDelta: max((maxLon - minLon) * 1.7, 0.02)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 10) {
                header

                ZStack {
                    Map(position: $camera, selection: $selectedVenueID) {
                        Marker("Home", systemImage: "house.fill", coordinate: EventLocations.homeCoordinate)
                            .tint(Theme.cyan)

                        ForEach(venues) { venue in
                            Marker(venue.name, systemImage: venue.symbol, coordinate: venue.coordinate)
                                .tint(Theme.violet)
                                .tag(venue.id)
                        }
                    }
                    .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
                    .overlay(alignment: .topLeading) {
                        legendChip
                    }
                    .overlay(alignment: .bottom) {
                        if let selectedVenue {
                            summaryCard(selectedVenue)
                                .padding(12)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.32, dampingFraction: 0.85), value: selectedVenueID)
                    .accessibilityLabel("Map of your saved venues")

                    if venues.isEmpty {
                        emptyState
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Text("Tap any pin to see the venue.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "91A8C8"))
                    .padding(.bottom, 6)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            camera = .region(mapRegion)
            if selectedVenueID == nil {
                selectedVenueID = venues.first?.id
            }
        }
        .sheet(item: $openedVenue) { venue in
            VenueDetailSheet(store: store, venue: venue, events: upcomingEvents(at: venue))
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            GlassIconButton(systemName: "arrow.left", size: 42, action: onBack)
                .accessibilityLabel("Back to saved venues")

            VStack(alignment: .leading, spacing: 3) {
                Text("Venues map")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .accessibilityAddTraits(.isHeader)

                Text("YOUR SAVED SPOTS")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(3.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)
        }
        .padding(.bottom, 2)
    }

    private var legendChip: some View {
        HStack(spacing: 5) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 9, weight: .bold))
            Text("Saved venues")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(Theme.cyan)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: "08101E", opacity: 0.82), in: Capsule())
        .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
        .padding(12)
    }

    private func summaryCard(_ venue: Venue) -> some View {
        HStack(spacing: 10) {
            VenueArtwork(venue: venue)
                .frame(width: 52, height: 52)
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
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)

                Text(eventCountLabel(for: venue))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 6) {
                Text(distanceLabel(to: venue))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .fixedSize()

                Button {
                    openedVenue = venue
                } label: {
                    Text("View venue")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.midnight)
                        .padding(.horizontal, 11)
                        .frame(height: 28)
                        .background(Capsule().fill(Theme.accent))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View \(venue.name)")
            }
        }
        .padding(10)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.8)
    }

    private var emptyState: some View {
        VStack(spacing: 9) {
            Image(systemName: "bookmark")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 54, height: 54)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))

            Text("No saved venues yet")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text("Save a venue on the Saved venues screen and it will appear here.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.78)
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

#Preview {
    VenuesMapView(store: SavedVenuesStore(), events: SampleEvents.events)
}
