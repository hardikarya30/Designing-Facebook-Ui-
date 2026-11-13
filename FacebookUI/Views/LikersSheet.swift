//
//  LikersSheet.swift
//  FacebookUI
//
//  Everyone who liked a post, with a follow button on each row.
//

import SwiftUI

struct LikersSheet: View {
    let count: Int

    @State private var followedIDs: Set<String> = Set(
        SampleLikers.people.filter { $0.isFollowing }.map(\.id)
    )

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(SampleLikers.people.enumerated()), id: \.element.id) { index, person in
                            row(person)

                            if index < SampleLikers.people.count - 1 {
                                Rectangle()
                                    .fill(Theme.hairline)
                                    .frame(height: 1)
                                    .padding(.leading, 68)
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
        HStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.rose)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.rose.opacity(0.15)))

            Text("\(count.formatted()) likes")
                .font(.headline)
                .foregroundStyle(Theme.primaryText)
                .contentTransition(.numericText())

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

    private func row(_ person: Liker) -> some View {
        let isFollowing = followedIDs.contains(person.id)

        return HStack(spacing: 12) {
            AvatarView(
                initials: person.initials,
                palette: person.palette,
                size: 46
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text("\(person.handle) · \(person.shared)")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if isFollowing {
                        followedIDs.remove(person.id)
                    } else {
                        followedIDs.insert(person.id)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    if isFollowing {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                    }

                    Text(isFollowing ? "Following" : "Follow")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(isFollowing ? Theme.secondaryText : Theme.cyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    Capsule(style: .continuous)
                        .fill(isFollowing ? Color.white.opacity(0.06) : Theme.cyan.opacity(0.16))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            isFollowing ? Color.white.opacity(0.12) : Theme.cyan.opacity(0.4),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

#Preview {
    LikersSheet(count: 249)
}
