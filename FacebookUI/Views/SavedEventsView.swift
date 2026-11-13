//
//  SavedEventsView.swift
//  FacebookUI
//
//  Search and manage bookmarked events.
//

import SwiftUI

struct SavedEventsView: View {
    @ObservedObject var store: EventsStore
    let onBack: () -> Void

    @State private var searchText = ""

    private var visibleEvents: [SocialEvent] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.savedEvents }
        return store.savedEvents.filter { event in
            event.title.localizedCaseInsensitiveContains(query)
                || event.location.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    header
                    searchField

                    if visibleEvents.isEmpty {
                        emptyState
                            .padding(.top, 2)
                    } else {
                        LazyVStack(spacing: 13) {
                            ForEach(visibleEvents) { event in
                                SavedEventCard(event: event) {
                                    withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                                        store.toggleSaved(event)
                                    }
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                            }
                        }
                    }

                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 14) {
            GlassIconButton(systemName: "arrow.left", size: 42, action: onBack)
                .accessibilityLabel("Back to events")

            VStack(alignment: .leading, spacing: 3) {
                Text("Saved events")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .accessibilityAddTraits(.isHeader)

                Text("PLANS WORTH KEEPING")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(3.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)
        }
        .padding(.bottom, 3)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search saved events", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search saved events")

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

    private var emptyState: some View {
        VStack(spacing: 11) {
            Image(systemName: searchText.isEmpty ? "bookmark" : "magnifyingglass")
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))

            Text(searchText.isEmpty ? "Nothing saved yet" : "No saved events found")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(searchText.isEmpty ? "Bookmark an event to keep it close." : "Try another event name or location.")
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
}

private struct SavedEventCard: View {
    let event: SocialEvent
    let onToggleSaved: () -> Void

    var body: some View {
        VStack(spacing: 9) {
            ZStack(alignment: .topLeading) {
                EventsArtwork(style: event.artwork)
                    .frame(height: 132)

                VStack(spacing: 1) {
                    Text(event.date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.9)
                        .foregroundStyle(Theme.cyan)
                    Text(event.date.formatted(.dateTime.day()))
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(event.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(Theme.cyan)
                }
                .frame(width: 48, height: 59)
                .background(Color(hex: "08101E", opacity: 0.82), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                .padding(10)

                Button(action: onToggleSaved) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .frame(width: 42, height: 42)
                        .glassSurface(cornerRadius: 21, tint: Color(hex: "10213D"), tintOpacity: 0.78)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(event.title) from saved events")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color(hex: "B7D4F7"))
                        Text(event.location)
                            .foregroundStyle(Color(hex: "AFC2DF"))
                            .lineLimit(1)
                    }
                    .font(.system(size: 12, weight: .medium))
                }

                Spacer(minLength: 2)

                HStack(spacing: 6) {
                    Image(systemName: "person.2")
                        .font(.system(size: 17, weight: .medium))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(attendeeCountLabel)
                            .font(.system(size: 12, weight: .medium))
                        Text("going")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundStyle(Color(hex: "B9C9E0"))
                .fixedSize()
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 2)
        }
        .padding(9)
        .glassSurface(cornerRadius: 23, tint: Color(hex: "142846"), tintOpacity: 0.72)
    }

    private var attendeeCountLabel: String {
        guard event.attendeeCount >= 1_000 else { return "\(event.attendeeCount)" }
        return String(format: "%.1fk", Double(event.attendeeCount) / 1_000)
    }
}

#Preview {
    SavedEventsView(store: EventsStore(), onBack: {})
}
