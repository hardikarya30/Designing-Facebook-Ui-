//
//  RootView.swift
//  FacebookUI
//
//  Hosts the selected tab above the floating glass navigation bar.
//

import SwiftUI

enum RootSheet: String, Identifiable {
    case search
    case discover
    case messages

    var id: String { rawValue }
}

struct RootView: View {
    var onSignOut: () -> Void = {}
    var onChangePassword: (String, String) -> Bool = { _, _ in false }
    var accountEmail: String = ""
    var accountPhone: String = ""
    var accountName: String = ""

    @StateObject private var store = FeedStore()
    @StateObject private var friendsStore = FriendsStore()
    @StateObject private var discoverStore = DiscoverStore()
    @StateObject private var messagesStore = MessagesStore()
    @StateObject private var notificationsStore = NotificationsStore()
    @StateObject private var profileStore = ProfileStore()
    @StateObject private var commentsStore = CommentsStore()
    @StateObject private var storiesStore = StoriesStore()
    @StateObject private var savedStore = SavedPostsStore()
    @StateObject private var pinnedStore = PinnedPostStore()
    @StateObject private var marketplaceStore = MarketplaceStore()
    @StateObject private var memoriesStore = MemoriesStore()
    @StateObject private var eventsStore = EventsStore()

    @State private var selection: AppTab = .home
    @State private var sheet: RootSheet?
    @State private var openedPost: Post?
    @State private var isSidebarPresented = false
    @State private var isGroupsPresented = false
    @State private var isMarketplacePresented = false
    @State private var isMemoriesPresented = false
    @State private var isEventsPresented = false
    @State private var isAddressPresented = false
    @State private var isDiscountsPresented = false
    @State private var isPlanPresented = false
    @State private var openedConversation: Conversation?

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()

            Group {
                if isPlanPresented {
                    YourPlanView(
                        onBack: { isPlanPresented = false },
                        stores: EventStores(
                            events: eventsStore,
                            messages: messagesStore,
                            feed: store,
                            comments: commentsStore,
                            saved: savedStore
                        )
                    )
                } else if isDiscountsPresented {
                    DiscountView(
                        onBack: { isDiscountsPresented = false },
                        stores: EventStores(
                            events: eventsStore,
                            messages: messagesStore,
                            feed: store,
                            comments: commentsStore,
                            saved: savedStore
                        )
                    )
                } else if isAddressPresented {
                    MyAddressView(
                        onBack: { isAddressPresented = false },
                        eventStores: EventStores(
                            events: eventsStore,
                            messages: messagesStore,
                            feed: store,
                            comments: commentsStore,
                            saved: savedStore
                        ),
                        onOpenEvents: {
                            isAddressPresented = false
                            isEventsPresented = true
                        }
                    )
                } else if isGroupsPresented {
                    GroupsView(onBack: { isGroupsPresented = false })
                } else if isEventsPresented {
                    EventsView(
                        store: eventsStore,
                        onBack: { isEventsPresented = false },
                        accountName: accountName,
                        messagesStore: messagesStore,
                        feedStore: store,
                        commentsStore: commentsStore,
                        savedStore: savedStore
                    )
                } else if isMemoriesPresented {
                    MemoriesView(
                        store: memoriesStore,
                        feedStore: store,
                        onBack: { isMemoriesPresented = false }
                    )
                } else if isMarketplacePresented {
                    MarketplaceView(
                        store: marketplaceStore,
                        onOpenMessages: { sheet = .messages },
                        onMessageSeller: { listing in
                            openedConversation = messagesStore.startMarketplaceConversation(for: listing)
                        }
                    )
                } else {
                    switch selection {
                    case .home:
                        HomeFeedView(
                            store: store,
                            storiesStore: storiesStore,
                            savedStore: savedStore,
                            pinnedStore: pinnedStore,
                            eventsStore: eventsStore,
                            messagesStore: messagesStore,
                            commentsStore: commentsStore,
                            authorName: accountName,
                            onMenu: { isSidebarPresented = true },
                            onSearch: { sheet = .search },
                            onMessages: { sheet = .messages },
                            onExplore: { sheet = .discover },
                            onSeeAllEvents: { isEventsPresented = true },
                            onOpenPlan: { isPlanPresented = true },
                            onOpenPost: { openedPost = $0 }
                        )
                    case .friends:
                        FriendsView(store: friendsStore)
                    case .alerts:
                        NotificationsView(store: notificationsStore)
                    case .profile:
                        ProfileView(
                            profileStore: profileStore,
                            feedStore: store,
                            savedStore: savedStore,
                            storiesStore: storiesStore,
                            pinnedStore: pinnedStore,
                            onOpenFriends: { selection = .friends },
                            onOpenPost: { openedPost = $0 },
                            onSignOut: onSignOut,
                            onChangePassword: onChangePassword,
                            accountEmail: accountEmail,
                            accountPhone: accountPhone,
                            accountName: accountName
                        )
                    default:
                        PlaceholderScreen(tab: selection)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomTabBar(
                selection: Binding(
                    get: { selection },
                    set: { newSelection in
                        selection = newSelection
                        isGroupsPresented = false
                        isMarketplacePresented = false
                        isMemoriesPresented = false
                        isEventsPresented = false
                        isAddressPresented = false
                        isDiscountsPresented = false
                        isPlanPresented = false
                    }
                ),
                alertsBadge: notificationsStore.unreadCount
            )
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $isSidebarPresented) {
            SideBarView(
                accountName: accountName,
                accountEmail: accountEmail,
                accountPhone: accountPhone,
                feedStore: store,
                savedStore: savedStore,
                storiesStore: storiesStore,
                messagesStore: messagesStore,
                commentsStore: commentsStore,
                discoverStore: discoverStore,
                onSelectTab: { selection = $0 },
                onOpenGroups: { isGroupsPresented = true },
                onOpenMarketplace: { isMarketplacePresented = true },
                onOpenMemories: { isMemoriesPresented = true },
                onOpenEvents: { isEventsPresented = true },
                onOpenAddress: { isAddressPresented = true },
                onOpenDiscounts: { isDiscountsPresented = true },
                onSignOut: onSignOut,
                onChangePassword: onChangePassword
            )
        }
        .sheet(item: $sheet) { presented in
            switch presented {
            case .search:
                SearchView(
                    messagesStore: messagesStore,
                    feedStore: store,
                    commentsStore: commentsStore,
                    savedStore: savedStore
                )
                .presentationDragIndicator(.hidden)
            case .discover:
                DiscoverView(store: discoverStore, feedStore: store, savedStore: savedStore)
                    .presentationDragIndicator(.hidden)
            case .messages:
                MessagesView(
                    store: messagesStore,
                    feedStore: store,
                    commentsStore: commentsStore,
                    savedStore: savedStore
                )
                .presentationDragIndicator(.hidden)
            }
        }
        .fullScreenCover(item: $openedPost) { post in
            PostDetailView(
                post: post,
                feedStore: store,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
        .fullScreenCover(item: $openedConversation) { conversation in
            ConversationView(
                conversation: conversation,
                store: messagesStore,
                feedStore: store,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
    }
}

#Preview {
    RootView()
}
