//
//  StoryComposerView.swift
//  FacebookUI
//
//  Write your own story: a gradient or a photo behind, a caption over it,
//  previewed as it will appear, then published to the stories row.
//

import SwiftUI

struct StoryComposerView: View {
    @ObservedObject var store: StoriesStore

    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var palette: MediaPalette = .dusk
    @State private var usesPhoto = false

    private let paletteOptions: [MediaPalette] = [.ocean, .dusk, .aurora]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 14) {
                header

                preview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                swatches

                captionField

                shareButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Your story")
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
    }

    // MARK: - Preview

    private var preview: some View {
        ZStack(alignment: .bottomLeading) {
            if usesPhoto {
                Color.clear
                    .overlay {
                        Image("FeedPhoto")
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                LinearGradient(
                    colors: palette.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(palette.glow.opacity(0.28))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .offset(x: -50, y: -70)

                Image(systemName: "sparkles")
                    .font(.system(size: 92, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .shadow(color: palette.glow.opacity(0.6), radius: 24)
            }

            LinearGradient(
                colors: [Color.black.opacity(0.25), Color.clear, Color.black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )

            if !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(caption)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassSurface(cornerRadius: 16, tintOpacity: 0.35, shadowed: false)
                    .padding(16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        }
    }

    // MARK: - Swatches

    private var swatches: some View {
        HStack(spacing: 10) {
            ForEach(paletteOptions, id: \.self) { option in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        usesPhoto = false
                        palette = option
                    }
                } label: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: option.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay {
                            if !usesPhoto && palette == option {
                                Circle().strokeBorder(Theme.cyan, lineWidth: 2.5)
                                    .padding(-4)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Gradient background")
            }

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    usesPhoto = true
                }
            } label: {
                Image("FeedPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay {
                        if usesPhoto {
                            Circle().strokeBorder(Theme.cyan, lineWidth: 2.5)
                                .padding(-4)
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Photo background")

            Spacer(minLength: 0)
        }
    }

    // MARK: - Caption

    private var captionField: some View {
        TextField("Add a caption…", text: $caption, axis: .vertical)
            .lineLimit(1...3)
            .font(.subheadline)
            .foregroundStyle(Theme.primaryText)
            .tint(Theme.cyan)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassSurface(cornerRadius: 18, shadowed: false)
    }

    // MARK: - Share

    private var shareButton: some View {
        Button {
            store.publish(
                caption: caption,
                palette: palette,
                imageName: usesPhoto ? "FeedPhoto" : nil
            )
            dismiss()
        } label: {
            Text("Share to story")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule(style: .continuous).fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.35), radius: 14, y: 7)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StoryComposerView(store: StoriesStore())
}
