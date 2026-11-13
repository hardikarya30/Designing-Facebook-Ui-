//
//  MessagesStore.swift
//  FacebookUI
//
//  Holds the inbox: the conversations, their unread counts and which
//  threads are muted.
//

import Combine
import Foundation

final class MessagesStore: ObservableObject {

    @Published private(set) var conversations: [Conversation] = SampleMessages.conversations
    @Published private(set) var mutedIDs: Set<String> = []
    @Published private(set) var threads: [String: [Message]] = [:]
    @Published private(set) var requests: [MessageRequest] = SampleMessages.requests
    @Published private(set) var pinnedIDs: Set<String> = []
    /// Reactions are kept for the session only.
    @Published private(set) var reactions: [String: MessageReaction] = [:]

    private let defaults: UserDefaults
    private let pinnedKey = "messages.pinnedIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var seeded = SampleMessages.threads

        for conversation in SampleMessages.conversations where seeded[conversation.id] == nil {
            seeded[conversation.id] = [
                Message(
                    id: "seed-\(conversation.id)",
                    text: conversation.preview,
                    isMine: false,
                    time: "9:41 AM"
                )
            ]
        }

        threads = seeded

        if let stored = defaults.stringArray(forKey: "messages.pinnedIDs") {
            pinnedIDs = Set(stored)
        } else {
            pinnedIDs = Set(SampleMessages.conversations.filter(\.isPinned).map(\.id))
        }
        applyPins()
    }

    func isPinned(_ conversation: Conversation) -> Bool {
        pinnedIDs.contains(conversation.id)
    }

    func reaction(for messageID: String) -> MessageReaction? {
        reactions[messageID]
    }

    func toggleReaction(_ reaction: MessageReaction, for messageID: String) {
        if reactions[messageID] == reaction {
            reactions.removeValue(forKey: messageID)
        } else {
            reactions[messageID] = reaction
        }
    }

    func removeReaction(for messageID: String) {
        reactions.removeValue(forKey: messageID)
    }

    func togglePin(_ conversation: Conversation) {
        if pinnedIDs.contains(conversation.id) {
            pinnedIDs.remove(conversation.id)
        } else {
            pinnedIDs.insert(conversation.id)
        }
        defaults.set(Array(pinnedIDs).sorted(), forKey: pinnedKey)
        applyPins()
    }

    private func applyPins() {
        for index in conversations.indices {
            conversations[index].isPinned = pinnedIDs.contains(conversations[index].id)
        }
    }

    func messages(for conversationID: String) -> [Message] {
        threads[conversationID] ?? []
    }

    func startMarketplaceConversation(for listing: MarketplaceListing) -> Conversation {
        let conversationID = "marketplace-\(listing.id)"
        if let existing = conversations.first(where: { $0.id == conversationID }) {
            return existing
        }

        let openingMessage = "Hi, is the \(listing.title) still available?"
        let conversation = Conversation(
            id: conversationID,
            name: listing.sellerName,
            initials: listing.sellerInitials,
            palette: listing.sellerPalette,
            preview: openingMessage,
            time: "Now",
            unreadCount: 0,
            isOnline: true,
            isPinned: false
        )
        conversations.insert(conversation, at: 0)
        threads[conversationID] = [
            Message(
                id: "\(conversationID)-opening",
                text: openingMessage,
                isMine: true,
                time: "Now"
            )
        ]
        return conversation
    }

    func append(_ message: Message, to conversationID: String) {
        threads[conversationID, default: []].append(message)
    }

    /// Opens (or reuses) a thread with the host of an event, seeded with a
    /// message that mentions the event.
    func startEventHostConversation(for event: SocialEvent) -> Conversation {
        let conversationID = "event-host-\(event.id)"
        if let existing = conversations.first(where: { $0.id == conversationID }) {
            return existing
        }

        let firstName = event.hostName
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init) ?? event.hostName
        let openingMessage = "Hi \(firstName), I'm coming to \(event.title) — just wanted to say hello."

        let conversation = Conversation(
            id: conversationID,
            name: event.hostName,
            initials: event.hostInitials,
            palette: event.hostPalette,
            preview: openingMessage,
            time: "Now",
            unreadCount: 0,
            isOnline: true,
            isPinned: false
        )
        conversations.insert(conversation, at: 0)
        threads[conversationID] = [
            Message(
                id: "\(conversationID)-opening",
                text: openingMessage,
                isMine: true,
                time: "Now"
            )
        ]
        return conversation
    }

    /// Opens (or reuses) a thread with plan support, seeded with a message that
    /// names the charge being asked about.
    func startPlanSupportConversation(dateText: String, amountText: String, invoiceNumber: String) -> Conversation {
        let conversationID = "plan-support-\(invoiceNumber)"
        let openingMessage = "Hi, I'd like some help with my \(amountText) charge on \(dateText) — invoice \(invoiceNumber)."

        if let existing = conversations.first(where: { $0.id == conversationID }) {
            if threads[conversationID]?.isEmpty ?? true {
                threads[conversationID] = [
                    Message(
                        id: "\(conversationID)-opening",
                        text: openingMessage,
                        isMine: true,
                        time: "Now"
                    )
                ]
            }
            return existing
        }

        let conversation = Conversation(
            id: conversationID,
            name: "Plan support",
            initials: "PS",
            palette: .azure,
            preview: openingMessage,
            time: "Now",
            unreadCount: 0,
            isOnline: true,
            isPinned: false
        )
        conversations.insert(conversation, at: 0)
        threads[conversationID] = [
            Message(
                id: "\(conversationID)-opening",
                text: openingMessage,
                isMine: true,
                time: "Now"
            )
        ]
        return conversation
    }

    @discardableResult
    func acceptRequest(_ request: MessageRequest) -> Conversation {
        requests.removeAll { $0.id == request.id }

        let conversation = Conversation(
            id: "request-\(request.id)",
            name: request.name,
            initials: request.initials,
            palette: request.palette,
            preview: request.preview,
            time: "Now",
            unreadCount: 0,
            isOnline: true,
            isPinned: false
        )

        if !conversations.contains(where: { $0.id == conversation.id }) {
            conversations.insert(conversation, at: 0)
        }

        return conversation
    }

    func deleteRequest(_ request: MessageRequest) {
        requests.removeAll { $0.id == request.id }
    }

    var unreadTotal: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    var pinned: [Conversation] {
        conversations.filter { $0.isPinned }
    }

    func isMuted(_ conversation: Conversation) -> Bool {
        mutedIDs.contains(conversation.id)
    }

    func toggleMute(_ conversation: Conversation) {
        if mutedIDs.contains(conversation.id) {
            mutedIDs.remove(conversation.id)
        } else {
            mutedIDs.insert(conversation.id)
        }
    }

    func markRead(_ conversation: Conversation) {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }),
              conversations[index].unreadCount > 0 else {
            return
        }

        conversations[index].unreadCount = 0
    }

    func delete(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        mutedIDs.remove(conversation.id)
    }
}
