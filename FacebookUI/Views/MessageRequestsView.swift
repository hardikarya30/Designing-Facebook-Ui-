//
//  MessageRequestsView.swift
//  FacebookUI
//
//  Messages from people you aren't friends with yet.
//

import SwiftUI

struct MessageRequestsView: View {
    @ObservedObject var store: MessagesStore
    @ObservedObject var feedStore: FeedStore
    @ObservedObject var commentsStore: CommentsStore
    @ObservedObject var savedStore: SavedPostsStore

    @Environment(\.dismiss) private var dismiss
    @State private var openedConversation: Conversation?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        if store.requests.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(store.requests.enumerated()), id: \.element.id) { index, request in
                                    requestRow(request)

                                    if index < store.requests.count - 1 {
                                        Rectangle()
                                            .fill(Theme.hairline)
                                            .frame(height: 1)
                                            .padding(.leading, 68)
                                    }
                                }
                            }
                            .glassSurface(cornerRadius: Theme.Radius.card)
                        }

                        Color.clear
                            .frame(height: 8)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $openedConversation) { conversation in
            ConversationView(
                conversation: conversation,
                store: store,
                feedStore: feedStore,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                GlassIconButton(systemName: "chevron.left", size: 40) {
                    dismiss()
                }
                .accessibilityLabel("Back")

                Spacer()
            }

            Text("Message requests")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text("People you're not friends with can message you here.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }

    private func requestRow(_ request: MessageRequest) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                AvatarView(
                    initials: request.initials,
                    palette: request.palette,
                    size: 52
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(request.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text(request.preview)
                        .font(.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text(request.time)
                    .font(.caption2)
                    .foregroundStyle(Theme.tertiaryText)
            }

            HStack(spacing: 10) {
                Button("Accept") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        let conversation = store.acceptRequest(request)
                        openedConversation = conversation
                    }
                }
                .buttonStyle(AcceptButtonStyle())

                Button("Delete") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        store.deleteRequest(request)
                    }
                }
                .buttonStyle(DeclineButtonStyle())
            }
        }
        .padding(14)
        .transition(.scale(scale: 0.94).combined(with: .opacity))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 68, height: 68)
                .glassSurface(cornerRadius: 34)

            Text("No message requests")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("You're all caught up.")
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .glassSurface(cornerRadius: Theme.Radius.card)
    }
}

#Preview {
    MessageRequestsView(
        store: MessagesStore(),
        feedStore: FeedStore(),
        commentsStore: CommentsStore(),
        savedStore: SavedPostsStore()
    )
}
