//
//  BottomTabBar.swift
//  FacebookUI
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case friends
    case create
    case alerts
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .friends: return "Friends"
        case .create: return "Create"
        case .alerts: return "Alerts"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .friends: return "person.2.fill"
        case .create: return "plus.square.fill"
        case .alerts: return "bell.fill"
        case .profile: return "person.crop.circle"
        }
    }
}

struct BottomTabBar: View {
    @Binding var selection: AppTab
    var alertsBadge: Int = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .glassSurface(cornerRadius: Theme.Radius.bar, tintOpacity: 0.62)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isActive = selection == tab

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isActive ? Theme.cyan : Theme.tertiaryText)
                    .shadow(color: Theme.cyan.opacity(isActive ? 0.7 : 0), radius: 8)
                    .overlay(alignment: .topTrailing) {
                        if tab == .alerts && alertsBadge > 0 {
                            Text(alertsBadge > 99 ? "99+" : "\(alertsBadge)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Theme.midnight)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Theme.cyan))
                                .offset(x: 10, y: -5)
                                .contentTransition(.numericText())
                        }
                    }

                Text(tab.title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isActive ? Theme.cyan : Theme.tertiaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Theme.cyan.opacity(isActive ? 0.12 : 0))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            tab == .alerts && alertsBadge > 0 ? "\(tab.title), \(alertsBadge) new" : tab.title
        )
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

#Preview {
    VStack {
        Spacer()
        BottomTabBar(selection: .constant(.home))
    }
    .background(AppBackground())
}
