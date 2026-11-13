//
//  MyAddressView.swift
//  FacebookUI
//
//  Your saved address on a map, with a link out to Google Maps.
//

import MapKit
import SwiftUI
import UIKit

struct MyAddressView: View {
    var onBack: () -> Void = {}
    var eventStores: EventStores? = nil
    var onOpenEvents: (() -> Void)? = nil

    @Environment(\.openURL) private var openURL
    @StateObject private var store = AddressStore()
    @StateObject private var remindersEvents = EventsStore()
    @StateObject private var remindersVenues = SavedVenuesStore()

    @State private var isEditing = false
    @State private var draftLines: [String] = []
    @State private var isWorkEditing = false
    @State private var workDraftLines: [String] = []
    @State private var didCopyAddress = false
    @State private var isNearbyPresented = false
    @State private var isSavedVenuesPresented = false
    @State private var isRemindersPresented = false

    private let coordinate = CLLocationCoordinate2D(latitude: 51.3695, longitude: -0.2260)

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )
    }

    /// While editing, the map and the header follow the text being typed.
    private var displayedLines: [String] {
        isEditing ? draftLines : store.lines
    }

    /// While editing, the work card follows the text being typed.
    private var displayedWorkLines: [String] {
        isWorkEditing ? workDraftLines : store.workLines
    }

    private var displayedAddress: String {
        displayedLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private var displayedArea: String {
        let cleaned = displayedLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard displayedLines.count > 3 else {
            return cleaned.last ?? ""
        }
        return "\(displayedLines[3]) · \(displayedLines[displayedLines.count - 1])"
    }

    private var displayedPostcode: String {
        displayedLines.last { line in
            line.contains(where: \.isNumber)
                && line.uppercased() == line
                && line.count <= 8
        } ?? ""
    }

    /// "Around North Cheam", built from the town line of the address.
    private var nearbyAreaLabel: String {
        let cleaned = displayedLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard cleaned.count > 3 else {
            guard let last = cleaned.last else { return "" }
            return "Around \(last)"
        }
        return "Around \(cleaned[3])"
    }

    /// The work address on the card: the building or flat first, then the rest.
    private var workAddressLines: [String] {
        let cleaned = displayedWorkLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard let first = cleaned.first else { return ["Studio 27"] }
        guard cleaned.count > 1 else { return [first] }

        return [first, cleaned.dropFirst().joined(separator: ", ")]
    }

    private var pinTitle: String {
        let first = displayedLines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return first.isEmpty ? "My address" : first
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    map
                    addressCard
                    workAddressCard
                    actions

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isNearbyPresented) {
            NearbyEventsSheet(
                homeCoordinate: coordinate,
                areaLabel: nearbyAreaLabel,
                postcode: displayedPostcode,
                events: eventStores?.events.events ?? SampleEvents.events,
                stores: eventStores,
                onOpenEvents: onOpenEvents
            )
        }
        .fullScreenCover(isPresented: $isSavedVenuesPresented) {
            SavedVenuesView(
                events: eventStores?.events.events ?? SampleEvents.events,
                onBack: { isSavedVenuesPresented = false }
            )
        }
        .fullScreenCover(isPresented: $isRemindersPresented) {
            RemindersScreenView(
                eventsStore: eventStores?.events ?? remindersEvents,
                venuesStore: remindersVenues,
                onBack: { isRemindersPresented = false }
            )
        }
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("My address")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .accessibilityAddTraits(.isHeader)

                Text(displayedArea.isEmpty ? "Your saved address" : displayedArea)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "A8B9D4"))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Color.clear.frame(width: 42, height: 42)
        }
    }

    private var map: some View {
        Map(initialPosition: .region(region)) {
            Marker(pinTitle, coordinate: coordinate)
                .tint(Theme.cyan)
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
        .frame(height: 246)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        }
        .overlay(alignment: .topLeading) {
            if !displayedPostcode.isEmpty {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text(displayedPostcode)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "08101E", opacity: 0.78), in: Capsule())
                .padding(12)
            }
        }
        .accessibilityLabel("Map showing \(displayedAddress)")
        .overlay(alignment: .bottomTrailing) {
            Button {
                isNearbyPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text("Near me")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Theme.midnight)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(Capsule().fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.34), radius: 12, y: 5)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Find events near me")
            .padding(12)
        }
    }

    private var addressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))

                Text(isEditing ? "Editing address" : "Home address")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Spacer(minLength: 8)

                if !isEditing {
                    Button {
                        startEditing()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .bold))
                            Text("Edit")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Theme.cyan)
                        .padding(.horizontal, 11)
                        .frame(height: 32)
                        .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit address")
                }
            }

            if isEditing {
                VStack(spacing: 8) {
                    ForEach(draftLines.indices, id: \.self) { index in
                        TextField("Address line \(index + 1)", text: $draftLines[index])
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.primaryText)
                            .tint(Theme.cyan)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
                            .accessibilityLabel("Address line \(index + 1)")
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        cancelEditing()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "D7E3F5"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Capsule().fill(Color.white.opacity(0.06)))
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel editing")

                    Button {
                        saveEditing()
                    } label: {
                        Text("Save")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.midnight)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Capsule().fill(Theme.accent))
                            .shadow(color: Theme.cyan.opacity(0.28), radius: 12, y: 5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Save address")
                }
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(displayedLines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 14, weight: line == displayedLines.last ? .medium : .semibold))
                            .foregroundStyle(
                                line == displayedLines.last
                                    ? AnyShapeStyle(Color(hex: "AFC2DF"))
                                    : AnyShapeStyle(Theme.primaryText)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.7)
    }

    private var workAddressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.violet)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.violet.opacity(0.12)))
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))

                Text(isWorkEditing ? "Editing work address" : "Work address")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Spacer(minLength: 8)

                if !isWorkEditing {
                    Button {
                        startEditingWork()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .bold))
                            Text("Edit")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Theme.violet)
                        .padding(.horizontal, 11)
                        .frame(height: 32)
                        .background(Capsule().fill(Theme.violet.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Theme.violet.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit work address")
                }
            }

            if isWorkEditing {
                VStack(spacing: 8) {
                    ForEach(workDraftLines.indices, id: \.self) { index in
                        TextField("Work address line \(index + 1)", text: $workDraftLines[index])
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.primaryText)
                            .tint(Theme.violet)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
                            .accessibilityLabel("Work address line \(index + 1)")
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        cancelEditingWork()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "D7E3F5"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Capsule().fill(Color.white.opacity(0.06)))
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel editing work address")

                    Button {
                        saveEditingWork()
                    } label: {
                        Text("Save")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.midnight)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Capsule().fill(Theme.accent))
                            .shadow(color: Theme.cyan.opacity(0.28), radius: 12, y: 5)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Save work address")
                }
            } else {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(workAddressLines.enumerated()), id: \.offset) { index, line in
                        Text(line)
                            .font(.system(size: 14, weight: index == workAddressLines.count - 1 ? .medium : .semibold))
                            .foregroundStyle(
                                index == workAddressLines.count - 1
                                    ? AnyShapeStyle(Color(hex: "AFC2DF"))
                                    : AnyShapeStyle(Theme.primaryText)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button {
                    openGoogleMaps(store.workFullAddress)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Open in Google Maps")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Theme.violet)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Capsule().fill(Theme.violet.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.violet.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open my work address in Google Maps")
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "221B3C"), tintOpacity: 0.7)
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                openGoogleMaps(displayedAddress)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Open in Google Maps")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Capsule().fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.32), radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open my address in Google Maps")

            Button {
                openGoogleMaps(displayedAddress, directions: true)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Directions")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "D7E3F5"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Get directions to my address")

            Button(action: copyAddress) {
                HStack(spacing: 8) {
                    Image(systemName: didCopyAddress ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Copy address")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "D7E3F5"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Copy my address")

            Button {
                isSavedVenuesPresented = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Saved venues")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "D7E3F5"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Saved venues")

            Button {
                isRemindersPresented = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Reminders")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "D7E3F5"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reminders")

            if didCopyAddress {
                Text("Address copied")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: didCopyAddress)
    }

    private func copyAddress() {
        UIPasteboard.general.string = displayedAddress

        withAnimation(.easeInOut(duration: 0.2)) {
            didCopyAddress = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.25)) {
                didCopyAddress = false
            }
        }
    }

    private func startEditing() {
        // Only one address card is edited at a time.
        isWorkEditing = false
        workDraftLines = []

        draftLines = store.lines
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isEditing = true
        }
    }

    private func cancelEditing() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isEditing = false
        }
        draftLines = []
    }

    private func saveEditing() {
        store.update(draftLines)
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isEditing = false
        }
        draftLines = []
    }

    private func startEditingWork() {
        // Only one address card is edited at a time.
        isEditing = false
        draftLines = []

        workDraftLines = store.workLines
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isWorkEditing = true
        }
    }

    private func cancelEditingWork() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isWorkEditing = false
        }
        workDraftLines = []
    }

    private func saveEditingWork() {
        store.updateWork(workDraftLines)
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            isWorkEditing = false
        }
        workDraftLines = []
    }

    private func openGoogleMaps(_ address: String, directions: Bool = false) {
        var components = URLComponents(string: directions
            ? "https://www.google.com/maps/dir/"
            : "https://www.google.com/maps/search/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: directions ? "destination" : "query", value: address)
        ]
        guard let url = components?.url else { return }
        openURL(url)
    }
}

#Preview {
    MyAddressView()
}
