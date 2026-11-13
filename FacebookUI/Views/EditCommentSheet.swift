//
//  EditCommentSheet.swift
//  FacebookUI
//
//  Edit the text of a comment you wrote.
//

import SwiftUI

struct EditCommentSheet: View {
    let comment: PostComment
    var onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String

    init(comment: PostComment, onSave: @escaping (String) -> Void) {
        self.comment = comment
        self.onSave = onSave
        _text = State(initialValue: comment.text)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 14) {
                header

                TextField("Comment", text: $text, axis: .vertical)
                    .lineLimit(2...5)
                    .font(.subheadline)
                    .foregroundStyle(Theme.primaryText)
                    .tint(Theme.cyan)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .glassSurface(cornerRadius: Theme.Radius.field, shadowed: false)

                Button {
                    onSave(text)
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
        .presentationDetents([.height(260)])
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("Edit comment")
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
    EditCommentSheet(comment: SampleComments.generic[0]) { _ in }
}
