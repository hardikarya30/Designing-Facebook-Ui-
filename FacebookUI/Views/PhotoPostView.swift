//
//  PhotoPostView.swift
//  FacebookUI
//
//  Share a picture: pick one from the library and write a caption.
//

import SwiftUI

struct PhotoPostView: View {
    @ObservedObject var store: FeedStore

    @Environment(\.dismiss) private var dismiss

    private let library = ["FeedPhoto", "ProfileCover", "ProfileAvatar", "ProfileLogo"]

    @State private var selectedImage = "FeedPhoto"
    @State private var caption = ""

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        grid
                        captionField
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)

                shareButton
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        ZStack {
            Text("New post")
                .font(.headline)
                .foregroundStyle(Theme.primaryText)

            HStack {
                GlassIconButton(systemName: "xmark", size: 36) {
                    dismiss()
                }
                .accessibilityLabel("Close")

                Spacer()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach(library, id: \.self) { name in
                Button {
                    selectedImage = name
                } label: {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 104)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    selectedImage == name ? Theme.cyan : Color.white.opacity(0.1),
                                    lineWidth: selectedImage == name ? 2.5 : 1
                                )
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Photo \(name)")
            }
        }
    }

    private var captionField: some View {
        TextField("Write a caption…", text: $caption, axis: .vertical)
            .lineLimit(2...4)
            .font(.subheadline)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.cyan)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassSurface(cornerRadius: 18, shadowed: false)
    }

    private var shareButton: some View {
        Button {
            store.publishPhoto(caption: caption, imageName: selectedImage)
            dismiss()
        } label: {
            Text("Share post")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Capsule(style: .continuous).fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.4), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PhotoPostView(store: FeedStore())
}
