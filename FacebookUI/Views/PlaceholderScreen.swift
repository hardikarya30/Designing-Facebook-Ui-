//
//  PlaceholderScreen.swift
//  FacebookUI
//
//  A quiet placeholder for the tabs that get their own screens next.
//

import SwiftUI

struct PlaceholderScreen: View {
    let tab: AppTab

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(tab.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .padding(.horizontal, 20)
                .padding(.top, 10)

            Spacer()

            VStack(spacing: 16) {
                ProfilePictureView(size: 82)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 240)
            }
            .frame(maxWidth: .infinity)

            Spacer()
            Spacer()
        }
        .padding(.bottom, 100)
    }

    private var message: String {
        switch tab {
        case .home:
            return ""
        case .friends:
            return "Friends and requests will appear here."
        case .create:
            return "Your composer opens here."
        case .alerts:
            return "Likes, comments and follows will show up here."
        case .profile:
            return "Your photos, bio and posts will live here."
        }
    }
}

#Preview {
    ZStack {
        AppBackground()
        PlaceholderScreen(tab: .friends)
    }
}
