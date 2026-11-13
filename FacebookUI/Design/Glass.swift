//
//  Glass.swift
//  FacebookUI
//
//  The reusable glass material: a frosted, translucent dark blue surface
//  with a hairline highlight, a soft sheen and a gentle drop shadow.
//

import SwiftUI

struct GlassSurface: View {
    var cornerRadius: CGFloat = Theme.Radius.card
    var tint: Color = Theme.deepBlue
    var tintOpacity: Double = 0.5

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        shape
            .fill(.ultraThinMaterial)
            .overlay {
                shape.fill(
                    LinearGradient(
                        colors: [tint.opacity(tintOpacity), Theme.ink.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .overlay {
                shape.fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.09), Color.white.opacity(0)],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.6)
                    )
                )
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
    }
}

extension View {
    /// Wraps the view in the app's signature frosted glass surface.
    func glassSurface(
        cornerRadius: CGFloat = Theme.Radius.card,
        tint: Color = Theme.deepBlue,
        tintOpacity: Double = 0.5,
        shadowed: Bool = true
    ) -> some View {
        self
            .background(
                GlassSurface(cornerRadius: cornerRadius, tint: tint, tintOpacity: tintOpacity)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: Color.black.opacity(shadowed ? 0.38 : 0),
                radius: 20,
                x: 0,
                y: 12
            )
    }
}

/// A circular glass button used in headers and toolbars.
struct GlassIconButton: View {
    let systemName: String
    var size: CGFloat = 44
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(Theme.primaryText.opacity(0.9))
                .frame(width: size, height: size)
        }
        .buttonStyle(GlassButtonStyle(cornerRadius: size / 2))
    }
}

struct GlassButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 22

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .glassSurface(cornerRadius: cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// The canvas behind every screen: midnight navy with two soft accent glows.
struct AppBackground: View {
    var body: some View {
        ZStack {
            Theme.midnight

            RadialGradient(
                colors: [Theme.cyan.opacity(0.14), Theme.cyan.opacity(0)],
                center: UnitPoint(x: 0.88, y: 0.02),
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [Theme.violet.opacity(0.16), Theme.violet.opacity(0)],
                center: UnitPoint(x: 0.02, y: 0.72),
                startRadius: 0,
                endRadius: 430
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        AppBackground()
        Text("social.")
            .font(.system(size: 30, weight: .heavy))
            .foregroundStyle(Theme.accent)
            .padding(24)
            .glassSurface(cornerRadius: Theme.Radius.card)
    }
}
