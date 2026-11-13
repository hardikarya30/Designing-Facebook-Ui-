//
//  SendPostSheet.swift
//  FacebookUI
//
//  Pick a post from the feed to send into a conversation.
//

import SwiftUI

struct SendPostSheet: View {
    let posts: [Post]
    var onSend: (Post) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            row(post)

                            if index < posts.count - 1 {
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(height: 1)
                                    .padding(.leading, 74)
                            }
                        }
                    }
                    .glassSurface(cornerRadius: Theme.Radius.card)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 20)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("Send a post")
                .font(.headline)
                .foregroundStyle(Theme.primaryText)

            Spacer(minLength: 8)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                    .overlay {
                        Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private func row(_ post: Post) -> some View {
        Button {
            onSend(post)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                thumbnail(post)

                VStack(alignment: .leading, spacing: 3) {
                    Text(post.caption)
                        .font(.subheadline)
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text("\(post.author.name) · \(post.likeCount.formatted()) likes")
                        .font(.caption2)
                        .foregroundStyle(Theme.tertiaryText)
                }

                Spacer(minLength: 8)

                Image(systemName: "paperplane.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Theme.cyan.opacity(0.2)))
                    .overlay {
                        Circle().strokeBorder(Theme.cyan.opacity(0.35), lineWidth: 1)
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func thumbnail(_ post: Post) -> some View {
        Group {
            if let imageName = post.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: post.media.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: post.symbol)
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.85))
                }
            }
        }
        .frame(width: 46, height: 46)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
