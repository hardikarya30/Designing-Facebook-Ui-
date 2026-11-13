//
//  MediaGalleryView.swift
//  FacebookUI
//
//  Everything you have shared as pictures: posts, stories and profile photos.
//

import SwiftUI

struct GalleryItem: Identifiable, Hashable {
    let id: String
    let imageName: String?
    let caption: String
    let symbol: String
    let media: MediaPalette
}

enum GalleryTab: String, CaseIterable, Identifiable {
    case photos = "Photos"
    case videos = "Videos"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct MediaGalleryView: View {
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var storiesStore: StoriesStore

    @Environment(\.dismiss) private var dismiss

    @State private var tab: GalleryTab = .photos
    @State private var selectedItem: GalleryItem?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        GallerySegmentedControl(selection: $tab)
                            .padding(.horizontal, 18)

                        if visibleItems.isEmpty {
                            emptyState
                                .padding(.horizontal, 18)
                        } else {
                            grid
                                .padding(.horizontal, 18)
                        }

                        Color.clear
                            .frame(height: 12)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $selectedItem) { item in
            GalleryPhotoView(item: item)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                GlassIconButton(systemName: "chevron.left", size: 40) {
                    dismiss()
                }
                .accessibilityLabel("Back")

                Spacer()
            }

            Text("Your media gallery")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(countLine)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }
}

// MARK: - Content

extension MediaGalleryView {

    private var photos: [GalleryItem] {
        var items: [GalleryItem] = []

        for post in feedStore.publishedPosts where post.imageName != nil {
            items.append(
                GalleryItem(
                    id: "post-\(post.id)",
                    imageName: post.imageName,
                    caption: post.caption,
                    symbol: post.symbol,
                    media: post.media
                )
            )
        }

        for story in storiesStore.myStories where story.imageName != nil {
            items.append(
                GalleryItem(
                    id: "story-\(story.id)",
                    imageName: story.imageName,
                    caption: story.caption,
                    symbol: story.symbol,
                    media: story.media
                )
            )
        }

        for photo in SampleProfile.photos {
            items.append(
                GalleryItem(
                    id: "profile-\(photo.id)",
                    imageName: nil,
                    caption: photo.caption,
                    symbol: photo.symbol,
                    media: photo.media
                )
            )
        }

        return items
    }

    private var videos: [GalleryItem] {
        []
    }

    private var visibleItems: [GalleryItem] {
        tab == .photos ? photos : videos
    }

    private var countLine: String {
        let total = visibleItems.count
        let noun: String

        switch tab {
        case .photos:
            noun = total == 1 ? "photo" : "photos"
        case .videos:
            noun = total == 1 ? "video" : "videos"
        }

        return "\(total) \(noun)"
    }

    private var emptyMessage: String {
        switch tab {
        case .photos:
            return "Nothing here yet — photos you share will show up."
        case .videos:
            return "Nothing here yet — videos you share will show up."
        }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3),
            spacing: 6
        ) {
            ForEach(visibleItems) { item in
                Button {
                    selectedItem = item
                } label: {
                    tile(item)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.caption.isEmpty ? "Photo" : item.caption)
            }
        }
    }

    private func tile(_ item: GalleryItem) -> some View {
        GalleryArtwork(item: item)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: tab == .photos ? "photo.stack" : "video")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 68, height: 68)
                .glassSurface(cornerRadius: 34)

            Text(emptyMessage)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }
}

// MARK: - Artwork

struct GalleryArtwork: View {
    let item: GalleryItem

    var body: some View {
        ZStack {
            if let imageName = item.imageName {
                Color.clear
                    .overlay {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: item.media.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(item.media.glow.opacity(0.25))
                .frame(width: 90, height: 90)
                .blur(radius: 24)

            Image(systemName: item.symbol)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.white.opacity(0.85))
        }
    }
}

// MARK: - Segmented control

struct GallerySegmentedControl: View {
    @Binding var selection: GalleryTab

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 4) {
            ForEach(GalleryTab.allCases) { item in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = item
                    }
                } label: {
                    Text(item.title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(selection == item ? Color.white : Theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selection == item {
                                Capsule(style: .continuous)
                                    .fill(Theme.accent)
                                    .matchedGeometryEffect(id: "galleryIndicator", in: indicator)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == item ? .isSelected : [])
            }
        }
        .padding(4)
        .glassSurface(cornerRadius: 24)
    }
}

// MARK: - Full-screen photo

struct GalleryPhotoView: View {
    let item: GalleryItem

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppBackground()

            VStack(spacing: 16) {
                Spacer(minLength: 0)

                GalleryArtwork(item: item)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.bar, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.Radius.bar, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.45), radius: 24, y: 12)

                if !item.caption.isEmpty {
                    Text(item.caption)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.primaryText.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            GlassIconButton(systemName: "xmark") {
                dismiss()
            }
            .padding(.trailing, 20)
            .padding(.top, 12)
            .accessibilityLabel("Close")
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MediaGalleryView(feedStore: FeedStore(), storiesStore: StoriesStore())
}
