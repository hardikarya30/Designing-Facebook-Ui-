//
//  CoverCard.swift
//  FacebookUI
//
//  The framed cover photo card: the image padded inside a frosted glass
//  frame, with a soft shadow on every side and any content laid over it.
//

import SwiftUI

struct CoverCard<OverlayContent: View>: View {
    var imageName: String = "ProfileCover"
    var imageHeight: CGFloat = 190
    var cornerRadius: CGFloat = 28
    var padding: CGFloat = 20
    @ViewBuilder var overlayContent: OverlayContent

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: imageHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.deepBlue.opacity(0.55), Theme.ink.opacity(0.45)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.38), radius: 24, x: 0, y: 12)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 0)
            .overlay(alignment: .bottom) {
                overlayContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
    }
}

#Preview {
    ZStack {
        AppBackground()
        CoverCard {
            ProfilePictureView(size: 104)
                .offset(y: 48)
        }
        .padding(.bottom, 56)
    }
}
