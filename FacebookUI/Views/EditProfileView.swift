//
//  EditProfileView.swift
//  FacebookUI
//
//  Edits the profile model; saving writes it to disk.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var store: ProfileStore

    @Environment(\.dismiss) private var dismiss
    @State private var draft: Profile

    init(store: ProfileStore) {
        self.store = store
        _draft = State(initialValue: store.profile)
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 12) {
                        field("Name", text: $draft.name)
                        field("Handle", text: $draft.handle)
                        field("Role", text: $draft.role)
                        field("Bio", text: $draft.bio, multiline: true)
                        field("Work", text: $draft.work)
                        field("Location", text: $draft.location)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
                .scrollDismissesKeyboard(.interactively)

                Button {
                    store.update(draft)
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
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("Edit profile")
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
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    private func field(_ title: String, text: Binding<String>, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.tertiaryText)

            TextField(title, text: text, axis: multiline ? .vertical : .horizontal)
                .font(.subheadline)
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .lineLimit(multiline ? 3 : 1)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .glassSurface(cornerRadius: Theme.Radius.field, shadowed: false)
        }
    }
}

#Preview {
    EditProfileView(store: ProfileStore())
}
