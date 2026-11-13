//
//  DiscoveryTopicsView.swift
//  FacebookUI
//
//  A discovery screen for the languages behind the web, one image card each.
//

import SwiftUI

struct DiscoveryTopicsView: View {
    @Environment(\.dismiss) private var dismiss

    private let topics = SampleDiscovery.topics

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    ForEach(topics) { topic in
                        card(topic)
                    }

                    Color.clear
                        .frame(height: 12)
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
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

            Text("Discovery")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text("The languages behind the web, one card at a time.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.bottom, 4)
    }

    private func card(_ topic: DiscoveryTopic) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            logo(topic)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)

                Text(topic.body)
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(12)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }

    private func logo(_ topic: DiscoveryTopic) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: topic.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RadialGradient(
                colors: [Color.white.opacity(0.35), Color.white.opacity(0)],
                center: UnitPoint(x: 0.28, y: 0.18),
                startRadius: 4,
                endRadius: 180
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text(topic.glyph)
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.28), radius: 10, y: 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: topic.colors[0].opacity(0.45), radius: 20, y: 10)
        .accessibilityLabel("\(topic.title) logo")
    }
}

#Preview {
    DiscoveryTopicsView()
}
