//
//  ShareVenueSheet.swift
//  FacebookUI
//
//  Pick one of your saved venues to send into a conversation.
//

import SwiftUI

struct ShareVenueSheet: View {
    var onSend: (Venue) -> Void

    @StateObject private var store = SavedVenuesStore()
    @Environment(\.dismiss) private var dismiss

    private var venues: [Venue] {
        store.venues.sorted {
            SampleVenues.distanceMiles(to: $0) < SampleVenues.distanceMiles(to: $1)
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    header

                    if venues.isEmpty {
                        emptyState
                    } else {
                        ForEach(venues) { venue in
                            row(venue)
                        }
                    }

                    Color.clear.frame(height: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Share a venue")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)

                Text("From your saved venues")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "A9BCD8"))
            }

            Spacer(minLength: 0)

            GlassIconButton(systemName: "xmark", size: 36) {
                dismiss()
            }
            .accessibilityLabel("Close")
        }
        .padding(.bottom, 2)
    }

    private func row(_ venue: Venue) -> some View {
        Button {
            onSend(venue)
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

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(10)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share \(venue.name)")
    }

    private var emptyState: some View {
        Text("No saved venues yet — save a venue from My address first.")
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
    ShareVenueSheet { _ in }
}
