//
//  ProfilePictureView.swift
//  FacebookUI
//
//  The signed-in user's picture in its cyan ring, with the studio logo as a
//  small badge. Shared by the profile's cover card and the placeholder screens.
//

import SwiftUI

struct ProfilePictureView: View {
    var size: CGFloat = 104
    var showsLogo: Bool = true
    var ringWidth: CGFloat = 3

    /// Keeps the logo badge in proportion when the picture is drawn smaller.
    private var badgeSize: CGFloat {
        max(20, size * 0.385)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image("ProfileAvatar")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay {
                    if ringWidth > 0 {
                        Circle()
                            .strokeBorder(Theme.accentDiagonal, lineWidth: ringWidth)
                            .padding(-(ringWidth + 1))
                    }
                }
                .shadow(color: Color.black.opacity(0.4), radius: 18, x: 0, y: 10)

            if showsLogo {
                logoBadge
                    .offset(x: size * 0.058, y: size * 0.058)
            }
        }
        .frame(width: size, height: size)
    }

    private var logoBadge: some View {
        Image("ProfileLogo")
            .resizable()
            .scaledToFit()
            .padding(badgeSize * 0.175)
            .frame(width: badgeSize, height: badgeSize)
            .background {
                Circle().fill(Color.white.opacity(0.94))
            }
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(Theme.accentDiagonal, lineWidth: 2)
                    .padding(-2)
            }
            .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HStack(spacing: 20) {
        ProfilePictureView(size: 104)
        ProfilePictureView(size: 80)
        ProfilePictureView(size: 56)
    }
    .padding()
    .background(AppBackground())
}
