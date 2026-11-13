//
//  NotificationsView.swift
//  FacebookUI
//
//  Activity grouped by time, with unread state driving the Alerts badge.
//

import SwiftUI

private enum NotificationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case unread = "Unread"
    case mentions = "Mentions"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct NotificationsView: View {
    @ObservedObject var store: NotificationsStore

    @State private var filter: NotificationFilter = .all

    private var visibleNotifications: [ActivityNotification] {
        switch filter {
        case .all:
            return store.notifications
        case .unread:
            return store.notifications.filter { !$0.isRead }
        case .mentions:
            return store.notifications.filter { $0.kind == .mention }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if !store.notifications.isEmpty {
                filterBar
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if visibleNotifications.isEmpty {
                        emptyState
                    } else {
                        ForEach(NotificationGroup.allCases) { group in
                            if !items(in: group).isEmpty {
                                section(group)
                            }
                        }
                    }

                    Color.clear
                        .frame(height: 104)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Filters

    private var filterBar: some View {
        HStack(spacing: 4) {
            ForEach(NotificationFilter.allCases) { option in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                        filter = option
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(option.title)

                        if option == .unread, store.unreadCount > 0 {
                            Text("\(store.unreadCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(filter == option ? Theme.deepBlue : Theme.cyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule().fill(
                                        filter == option
                                            ? Color.white.opacity(0.76)
                                            : Theme.cyan.opacity(0.14)
                                    )
                                }
                        }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(filter == option ? .white : Color(hex: "AFC2DF"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background {
                        if filter == option {
                            Capsule()
                                .fill(Theme.accent)
                                .shadow(color: Theme.cyan.opacity(0.4), radius: 8)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(filter == option ? .isSelected : [])
                .accessibilityLabel("\(option.title) notifications")
            }
        }
        .padding(4)
        .glassSurface(cornerRadius: 24, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Notifications")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            if !store.notifications.isEmpty {
                Button(action: performPrimaryAction) {
                    Text(actionTitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.primaryText.opacity(0.9))
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .glassSurface(cornerRadius: 18, shadowed: false)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private var subtitle: String {
        let unread = store.unreadCount
        return unread == 0 ? "All caught up" : "\(unread) new"
    }

    private var actionTitle: String {
        store.unreadCount > 0 ? "Mark all read" : "Clear all"
    }

    private func performPrimaryAction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            if store.unreadCount > 0 {
                store.markAllRead()
            } else {
                store.clearAll()
            }
        }
    }

    // MARK: - Sections

    private func items(in group: NotificationGroup) -> [ActivityNotification] {
        visibleNotifications.filter { $0.group == group }
    }

    private func section(_ group: NotificationGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Theme.tertiaryText)

            ForEach(items(in: group)) { notification in
                row(notification)
            }
        }
    }

    private func row(_ notification: ActivityNotification) -> some View {
        let isRead = notification.isRead

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                store.markRead(notification)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(
                    initials: notification.initials,
                    palette: notification.palette,
                    size: 44
                )
                .overlay(alignment: .bottomTrailing) {
                    badge(for: notification.kind)
                        .offset(x: 5, y: 5)
                }

                VStack(alignment: .leading, spacing: 4) {
                    titleText(notification)

                    Text(notification.time)
                        .font(.caption2)
                        .foregroundStyle(isRead ? Theme.tertiaryText : Theme.cyan)
                }

                Spacer(minLength: 8)

                if !isRead {
                    Circle()
                        .fill(Theme.cyan)
                        .frame(width: 7, height: 7)
                        .padding(.top, 6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassSurface(
                cornerRadius: 22,
                tint: isRead ? Theme.deepBlue : Theme.cyan,
                tintOpacity: isRead ? 0.42 : 0.14,
                shadowed: false
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(notification.actorName) \(notification.message), \(notification.time)"
        )
    }

    private func titleText(_ notification: ActivityNotification) -> some View {
        (Text(notification.actorName).bold() + Text(" " + notification.message))
            .font(.subheadline)
            .foregroundStyle(
                notification.isRead
                    ? Theme.primaryText.opacity(0.72)
                    : Theme.primaryText.opacity(0.95)
            )
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func badge(for kind: NotificationKind) -> some View {
        Image(systemName: kind.icon)
            .font(.system(size: 7, weight: .bold))
            .foregroundStyle(kind.tint)
            .frame(width: 17, height: 17)
            .background(Circle().fill(Theme.midnight))
            .overlay {
                Circle().strokeBorder(kind.tint.opacity(0.55), lineWidth: 1)
            }
            .accessibilityLabel(kind.label)
    }

    // MARK: - Empty

    private var emptyTitle: String {
        switch filter {
        case .all: return "You're all caught up"
        case .unread: return "Nothing unread"
        case .mentions: return "No mentions yet"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .all:
            return "New likes, comments and follows will land here."
        case .unread:
            return "You've read everything here. Switch to All to see it again."
        case .mentions:
            return "When someone tags you in a post, it will show up here."
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: filter == .unread ? "checkmark.circle" : "bell")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 76, height: 76)
                .glassSurface(cornerRadius: 38)

            VStack(spacing: 6) {
                Text(emptyTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                Text(emptyMessage)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 240)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppBackground()
        NotificationsView(store: NotificationsStore())
        BottomTabBar(selection: .constant(.alerts), alertsBadge: 4)
    }
    .preferredColorScheme(.dark)
}
