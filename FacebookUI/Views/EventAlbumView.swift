//
//  EventAlbumView.swift
//  FacebookUI
//
//  An event's shared photo album, with tiles, filters and a full screen viewer.
//

import SwiftUI

struct EventAlbumView: View {
    let event: SocialEvent
    @ObservedObject var store: EventAlbumStore
    var onBack: () -> Void

    @State private var filter: AlbumFilter = .all
    @State private var selectedPhoto: EventAlbumPhoto?
    @State private var newestPhotoID: String?

    private enum AlbumFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case photos = "Photos"
        case yours = "Yours"

        var id: String { rawValue }
    }

    private var allPhotos: [EventAlbumPhoto] {
        store.photos(for: event)
    }

    private var visiblePhotos: [EventAlbumPhoto] {
        switch filter {
        case .all:
            return allPhotos
        case .photos:
            return allPhotos.filter { !$0.isMine }
        case .yours:
            return allPhotos.filter(\.isMine)
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header
                filters
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if visiblePhotos.isEmpty {
                            emptyState
                        } else {
                            grid
                        }

                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $selectedPhoto) { photo in
            EventAlbumPhotoView(photo: photo)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            GlassIconButton(systemName: "chevron.left", size: 42) {
                onBack()
            }
            .accessibilityLabel("Back to events")

            Spacer(minLength: 6)

            VStack(spacing: 2) {
                Text(event.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .accessibilityAddTraits(.isHeader)

                Text(photoCountText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
            }

            Spacer(minLength: 6)

            Button(action: addPhoto) {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text("Add photo")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add a photo to \(event.title)")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var photoCountText: String {
        let count = allPhotos.count
        if count == 0 { return "No photos" }
        return count == 1 ? "1 photo" : "\(count) photos"
    }

    private var filters: some View {
        HStack(spacing: 4) {
            ForEach(AlbumFilter.allCases) { option in
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

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach(visiblePhotos) { photo in
                Button {
                    selectedPhoto = photo
                } label: {
                    tile(photo)
                        .overlay(alignment: .topTrailing) {
                            if photo.id == newestPhotoID {
                                Text("NEW")
                                    .font(.system(size: 8, weight: .bold))
                                    .tracking(0.6)
                                    .foregroundStyle(Theme.midnight)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Theme.cyan))
                                    .padding(6)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(photo.isMine ? "Your photo in the album" : "Photo in the album")
            }
        }
    }

    private func tile(_ photo: EventAlbumPhoto) -> some View {
        ZStack {
            if let imageName = photo.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: photo.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 80, height: 80)
                    .blur(radius: 1)
                    .offset(x: 22, y: -26)

                Image(systemName: photo.symbol)
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.86))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 68, height: 68)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))

            Text(emptyTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(emptyMessage)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.46, shadowed: false)
    }

    private var emptyTitle: String {
        filter == .yours ? "No photos of yours yet" : "No photos yet"
    }

    private var emptyMessage: String {
        filter == .yours
            ? "Tap Add photo and your picture will appear here."
            : "No photos yet — add the first one."
    }

    private func addPhoto() {
        guard let photo = store.addPhoto(to: event) else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            filter = .all
            newestPhotoID = photo.id
        }
    }
}

struct EventAlbumPhotoView: View {
    let photo: EventAlbumPhoto

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.midnightDeep
                .ignoresSafeArea()

            artwork
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
                .padding(.horizontal, 20)

            VStack {
                HStack {
                    Spacer()

                    GlassIconButton(systemName: "xmark", size: 40) {
                        dismiss()
                    }
                    .accessibilityLabel("Close photo")
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var artwork: some View {
        if let imageName = photo.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(
                    colors: photo.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .offset(x: 70, y: -90)

                Image(systemName: photo.symbol)
                    .font(.system(size: 84, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .shadow(color: photo.media.glow.opacity(0.5), radius: 24)
            }
        }
    }
}
