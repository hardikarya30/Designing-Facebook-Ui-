//
//  StoryViewersSheet.swift
//  FacebookUI
//
//  Who watched your story, with a heart on the people who reacted.
//

import SwiftUI

struct StoryViewersSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(SampleStoryViewers.people.enumerated()), id: \.element.id) { index, person in
                            row(person)

                            if index < SampleStoryViewers.people.count - 1 {
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
            Image(systemName: "eye.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.cyan.opacity(0.15)))

            Text("\(SampleStoryViewers.total.formatted()) views")
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

    private func row(_ person: StoryViewerPerson) -> some View {
        HStack(spacing: 12) {
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

                Text("\(person.handle) · \(person.time)")
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if person.reacted {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9, weight: .bold))

                    Text("1")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Theme.rose)
                .accessibilityLabel("Reacted with a heart")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

#Preview {
    StoryViewersSheet()
}
