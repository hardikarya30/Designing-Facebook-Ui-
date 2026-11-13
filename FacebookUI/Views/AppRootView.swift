//
//  AppRootView.swift
//  FacebookUI
//
//  Shows the sign in screens until you are signed in, then the app.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var auth = AuthStore()

    var body: some View {
        Group {
            if auth.isSignedIn {
                RootView(
                    onSignOut: { auth.signOut() },
                    onChangePassword: { currentPassword, newPassword in
                        auth.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                    },
                    accountEmail: auth.email,
                    accountPhone: auth.phone,
                    accountName: auth.name
                )
            } else {
                AuthView(auth: auth)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AppRootView()
}
