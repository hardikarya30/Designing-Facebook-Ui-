//
//  EditPostSheet.swift
//  FacebookUI
//
//  Edit the caption of a post you wrote.
//

import SwiftUI

struct EditPostSheet: View {
    let post: Post
    var onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var caption: String

    init(post: Post, onSave: @escaping (String) -> Void) {
        self.post = post
        self.onSave = onSave
        _caption = State(initialValue: post.caption)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 14) {
                header

                TextField("Caption", text: $caption, axis: .vertical)
                    .lineLimit(3...6)
                    .font(.subheadline)
                    .foregroundStyle(Theme.primaryText)
                    .tint(Theme.cyan)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .glassSurface(cornerRadius: Theme.Radius.field, shadowed: false)

                Button {
                    onSave(caption.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                } label: {
                    Text("Save changes")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.midnight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Capsule(style: .continuous).fill(Theme.accent))
                        .shadow(color: Theme.cyan.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("Edit post")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.primaryText)

            Spacer()

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
    }
}

#Preview {
    EditPostSheet(post: SampleFeed.posts[0]) { _ in }
}
