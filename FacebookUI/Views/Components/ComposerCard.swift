//
//  ComposerCard.swift
//  FacebookUI
//

import SwiftUI

struct ComposerCard: View {
    @Binding var text: String
    var onAddPhoto: () -> Void = {}
    var onSend: () -> Void

    @FocusState private var isFocused: Bool

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: Author.me.initials,
                palette: Author.me.palette,
                size: 36
            )

            TextField("What's on your mind?", text: $text, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .lineLimit(1...4)
                .focused($isFocused)

            Button(action: onAddPhoto) {
                Image(systemName: "photo")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(width: 36, height: 36)
                    .background {
                        Circle().fill(Color.white.opacity(0.05))
                    }
                    .overlay {
                        Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add a photo")

            Button {
                onSend()
                isFocused = false
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(canSend ? Theme.cyan : Theme.tertiaryText)
                    .frame(width: 36, height: 36)
                    .background {
                        Circle()
                            .fill(canSend ? Theme.cyan.opacity(0.16) : Color.white.opacity(0.05))
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(
                                canSend ? Theme.cyan.opacity(0.4) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .animation(.easeOut(duration: 0.2), value: canSend)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassSurface(cornerRadius: 22)
    }
}

#Preview {
    VStack {
        Spacer()
        ComposerCard(text: .constant(""), onSend: {})
        ComposerCard(text: .constant("Sending the final palette tonight"), onSend: {})
        Spacer()
    }
    .padding()
    .background(AppBackground())
}
