//
//  NotificationsStore.swift
//  FacebookUI
//
//  Holds the activity list and its read state, which drives the badge
//  on the Alerts tab.
//

import Combine
import Foundation

final class NotificationsStore: ObservableObject {

    @Published private(set) var notifications: [ActivityNotification] = SampleNotifications.items

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func markRead(_ notification: ActivityNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }),
              !notifications[index].isRead else {
            return
        }

        notifications[index].isRead = true
    }

    func markAllRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    func clearAll() {
        notifications.removeAll()
    }
}
