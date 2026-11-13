//
//  AvatarView.swift
//  FacebookUI
//

import SwiftUI

enum AvatarPalette: String, CaseIterable, Hashable, Codable {
    case cyan
    case azure
    case violet
    case orchid
    case mint
    case amber

    var colors: [Color] {
        switch self {
        case .cyan:
            return [Color(hex: "22D8FF"), Color(hex: "1B4C9B")]
        case .azure:
            return [Color(hex: "4D8BFF"), Color(hex: "17255F")]
        case .violet:
            return [Color(hex: "A78BFA"), Color(hex: "4A2C86")]
        case .orchid:
            return [Color(hex: "F2A6FF"), Color(hex: "6B2F92")]
        case .mint:
            return [Color(hex: "4EE1C1"), Color(hex: "0F6B62")]
        case .amber:
            return [Color(hex: "FFC078"), Color(hex: "9A4A1E")]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var accent: Color {
        colors[0]
    }
}

struct AvatarView: View {
    let initials: String
    var palette: AvatarPalette = .cyan
    var size: CGFloat = 42
    var ringWidth: CGFloat = 0
    /// The picture drawn inside the avatar. Set to nil to fall back to initials.
    var imageName: String? = "ProfileAvatar"

    var body: some View {
        ZStack {
            Circle()
                .fill(palette.gradient)

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.16), Color.white.opacity(0)],
                            center: UnitPoint(x: 0.3, y: 0.2),
                            startRadius: 0,
                            endRadius: size * 0.8
                        )
                    )
                    .blendMode(.plusLighter)
            } else {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.32), Color.white.opacity(0)],
                            center: UnitPoint(x: 0.3, y: 0.2),
                            startRadius: 0,
                            endRadius: size * 0.8
                        )
                    )

                Text(initials)
                    .font(.system(size: size * 0.34, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.95))
                    .kerning(0.5)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        }
        .overlay {
            if ringWidth > 0 {
                Circle()
                    .strokeBorder(Theme.accentDiagonal, lineWidth: ringWidth)
                    .padding(-ringWidth - 3)
            }
        }
    }
}

#Preview {
    HStack(spacing: 14) {
        ForEach(AvatarPalette.allCases, id: \.self) { palette in
            AvatarView(initials: "AM", palette: palette, size: 48, ringWidth: 2)
        }
    }
    .padding()
    .background(AppBackground())
}
