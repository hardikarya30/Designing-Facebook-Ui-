//
//  EventsArtwork.swift
//  FacebookUI
//
//  Original vector illustrations for sample event cards.
//

import SwiftUI

struct EventsArtwork: View {
    let style: EventArtworkStyle

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: style.colors, startPoint: .topLeading, endPoint: .bottomTrailing)

                Circle()
                    .fill(Color.white.opacity(0.13))
                    .frame(width: proxy.size.height * 1.45, height: proxy.size.height * 1.45)
                    .blur(radius: 1)
                    .offset(x: proxy.size.width * 0.33, y: -proxy.size.height * 0.6)

                Circle()
                    .strokeBorder(Color.white.opacity(0.13), lineWidth: 1)
                    .frame(width: proxy.size.height * 1.2, height: proxy.size.height * 1.2)
                    .offset(x: -proxy.size.width * 0.35, y: proxy.size.height * 0.66)

                Image(systemName: style.symbol)
                    .font(.system(size: proxy.size.height * 0.48, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.white.opacity(0.88))
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 7)
                    .offset(x: proxy.size.width * 0.18, y: 1)

                Image(systemName: "sparkle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.74))
                    .offset(x: -proxy.size.width * 0.3, y: -proxy.size.height * 0.2)

                Image(systemName: "sparkle")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.58))
                    .offset(x: proxy.size.width * 0.04, y: -proxy.size.height * 0.34)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .accessibilityHidden(true)
    }
}
