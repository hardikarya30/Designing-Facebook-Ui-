//
//  EventDiscussionSection.swift
//  FacebookUI
//
//  The discussion thread under an event's description, with its own composer.
//

import SwiftUI

struct EventDiscussionSection: View {
    let event: SocialEvent
    var authorName: String = "You"

    @StateObject private var store = EventDiscussionStore()
    @State private var draft = ""

    private var thread: [EventDiscussionMessage] {
        store.messages(for: event)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Discussion")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 8)

                Text(messageCountText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(.horizontal, 3)

            if thread.isEmpty {
                Text("No messages yet — start the conversation.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .glassSurface(cornerRadius: 18, tintOpacity: 0.42, shadowed: false)
            } else {
                VStack(spacing: 9) {
                    ForEach(thread) { message in
                        bubble(message)
                    }
                }
            }

            composer
        }
        .padding(.top, 2)
    }

    private var messageCountText: String {
        guard !thread.isEmpty else { return "No messages" }
        return thread.count == 1 ? "1 message" : "\(thread.count) messages"
    }

    private func bubble(_ message: EventDiscussionMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(
                initials: message.initials,
                palette: message.palette,
                size: 34,
                imageName: nil
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(message.authorName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)

                    Text(message.relativeTime)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.tertiaryText)
                }

                Text(message.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "E2EAF7"))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassSurface(
                cornerRadius: 16,
                tint: message.isMine ? Theme.cyan : Theme.deepBlue,
                tintOpacity: message.isMine ? 0.16 : 0.5,
                shadowed: false
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.authorName), \(message.relativeTime). \(message.text)")
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Add to the discussion", text: $draft, axis: .vertical)
                .font(.system(size: 14))
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1...3)
                .tint(Theme.cyan)
                .autocorrectionDisabled()
                .accessibilityLabel("Message about \(event.title)")

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(canSend ? Theme.midnight : Theme.tertiaryText)
                    .frame(width: 34, height: 34)
                    .background {
                        if canSend {
                            Circle().fill(Theme.accent)
                        } else {
                            Circle().fill(Color.white.opacity(0.07))
                        }
                    }
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "10213C"), tintOpacity: 0.55, shadowed: false)
    }

    private func send() {
        guard canSend else { return }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            store.send(draft, in: event, authorName: authorName)
        }
        draft = ""
    }
}
