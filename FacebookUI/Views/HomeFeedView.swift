//
//  HomeFeedView.swift
//  FacebookUI
//
//  The feed: wordmark header, stories, the composer and the post cards.
//

import SwiftUI

struct HomeFeedView: View {
    @ObservedObject var store: FeedStore
    @ObservedObject var storiesStore: StoriesStore
    @ObservedObject var savedStore: SavedPostsStore
    @ObservedObject var pinnedStore: PinnedPostStore
    @ObservedObject var eventsStore: EventsStore
    @ObservedObject var messagesStore: MessagesStore
    @ObservedObject var commentsStore: CommentsStore
    var authorName: String = "You"
    var onMenu: () -> Void = {}
    var onSearch: () -> Void = {}
    var onMessages: () -> Void = {}
    var onExplore: () -> Void = {}
    var onSeeAllEvents: () -> Void = {}
    var onOpenPlan: () -> Void = {}
    var onOpenPost: (Post) -> Void = { _ in }

    @AppStorage("plan.cancelled") private var planCancelled = false
    @AppStorage("plan.yearly") private var planYearly = false
    @AppStorage("plan.paused") private var planPaused = false

    @State private var selectedStory: Story?
    @State private var isComposerPresented = false
    @State private var editingPost: Post?
    @State private var pendingDelete: Post?
    @State private var isPhotoPostPresented = false
    @State private var openedEvent: SocialEvent?

    var body: some View {
        VStack(spacing: 0) {
            HomeHeader(onMenu: onMenu, onSearch: onSearch, onMessages: onMessages, onExplore: onExplore)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    stories

                    planCard

                    upcomingEventsCard

                    ComposerCard(
                        text: $store.draftText,
                        onAddPhoto: { isPhotoPostPresented = true }
                    ) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            store.publishDraft()
                        }
                    }

                    feed

                    Color.clear
                        .frame(height: 104)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .fullScreenCover(item: $selectedStory) { story in
            StoryViewer(stories: storiesStore.viewerStories, startID: story.id)
        }
        .fullScreenCover(isPresented: $isComposerPresented) {
            StoryComposerView(store: storiesStore)
        }
        .fullScreenCover(isPresented: $isPhotoPostPresented) {
            PhotoPostView(store: store)
        }
        .fullScreenCover(item: $openedEvent) { event in
            EventDetailsView(
                event: event,
                response: eventsStore.response(for: event),
                onBack: { openedEvent = nil },
                onResponse: { eventsStore.setResponse($0, for: event) },
                isReminded: eventsStore.isReminded(event),
                reminderDate: eventsStore.reminderDate(for: event),
                onToggleReminder: { eventsStore.toggleReminder(event) },
                authorName: authorName,
                isPinned: eventsStore.isPinned(event),
                onTogglePin: { eventsStore.togglePin(event) },
                rating: eventsStore.rating(for: event),
                onRate: { eventsStore.setRating($0, for: event) },
                messagesStore: messagesStore,
                feedStore: store,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
        .sheet(item: $editingPost) { post in
            EditPostSheet(post: post) { caption in
                withAnimation(.easeOut(duration: 0.2)) {
                    store.updateCaption(caption, for: post.id)
                }
            }
        }
        .confirmationDialog(
            "Delete this post?",
            isPresented: deleteDialogBinding,
            titleVisibility: .visible,
            presenting: pendingDelete
        ) { post in
            Button("Delete", role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    store.delete(post.id)
                }
                pendingDelete = nil
            }

            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: { _ in
            Text("This can't be undone.")
        }
    }

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { isPresented in
                if !isPresented { pendingDelete = nil }
            }
        )
    }

    private var stories: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stories")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SampleFeed.stories) { story in
                        if story.isMine {
                            Button {
                                isComposerPresented = true
                            } label: {
                                StoryRingView(story: story, hasStory: storiesStore.hasStory)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Add to your story")
                        } else {
                            Button {
                                selectedStory = story
                            } label: {
                                StoryRingView(story: story)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open \(story.name)'s story")
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var planPriceText: String {
        let amount: Double = planYearly ? 2500 : 250
        return "£" + amount.formatted(.number.precision(.fractionLength(0)))
    }

    private var planUnitText: String {
        planYearly ? "/ year" : "/ month"
    }

    /// The day the plan next renews, a month or a year out, pushed on again while paused.
    private var planRenewalText: String {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: planYearly ? .year : .month, value: 1, to: Date()) ?? Date()
        let date = planPaused ? (calendar.date(byAdding: .month, value: 1, to: base) ?? base) : base

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM"
        return "Renews " + formatter.string(from: date)
    }

    @ViewBuilder
    private var planCard: some View {
        if !planCancelled {
            Button {
                onOpenPlan()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.violet)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Theme.violet.opacity(0.16)))
                        .overlay {
                            Circle().strokeBorder(Theme.violet.opacity(0.3), lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Your plan")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Color(hex: "AFC2DF"))

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(planPriceText)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primaryText)

                            Text(planUnitText)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(hex: "AFC2DF"))
                        }

                        Text(planRenewalText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.cyan)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.tertiaryText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.66)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Your plan, \(planPriceText) \(planUnitText), \(planRenewalText)")
            .accessibilityHint("Opens your plan")
        }
    }

    private var upcomingEvents: [SocialEvent] {
        var events = eventsStore.events.filter { !$0.isInvitation && $0.endDate > Date() }

        if let pinnedID = eventsStore.pinnedID,
           let index = events.firstIndex(where: { $0.id == pinnedID }) {
            let pinned = events.remove(at: index)
            events.insert(pinned, at: 0)
        }

        return Array(events.prefix(2))
    }

    @ViewBuilder
    private var upcomingEventsCard: some View {
        let events = upcomingEvents

        if !events.isEmpty {
            VStack(spacing: 0) {
                HStack {
                    Text("Upcoming events")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Spacer()

                    Button {
                        onSeeAllEvents()
                    } label: {
                        Text("See all")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.cyan)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("See all events")
                }
                .padding(.horizontal, 14)
                .padding(.top, 13)
                .padding(.bottom, 10)

                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    if index > 0 {
                        Rectangle()
                            .fill(Theme.hairline)
                            .frame(height: 1)
                            .padding(.leading, 74)
                    }

                    Button {
                        openedEvent = event
                    } label: {
                        HStack(spacing: 12) {
                            VStack(spacing: 1) {
                                Text(event.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(Theme.cyan)
                                Text(event.date.formatted(.dateTime.day()))
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 44, height: 44)
                            .background(Color(hex: "08101E", opacity: 0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(event.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.primaryText)
                                    .lineLimit(1)

                                Text(event.location)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Color(hex: "AFC2DF"))
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 8)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.tertiaryText)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(event.title), \(event.location)")
                }
            }
            .padding(.bottom, 4)
            .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.66)
        }
    }

    private var feed: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Feed")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.primaryText)

            ForEach(store.posts) { post in
                PostCardView(
                    post: post,
                    isLiked: store.isLiked(post.id),
                    isMine: store.isMine(post),
                    isSaved: savedStore.isSaved(post.id),
                    isPinned: pinnedStore.isPinned(post.id),
                    onEdit: { editingPost = post },
                    onDelete: { pendingDelete = post },
                    onToggleSave: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            savedStore.toggle(post.id)
                        }
                    },
                    onTogglePin: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            pinnedStore.toggle(post)
                        }
                    }
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                        store.toggleLike(post.id)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                .onTapGesture {
                    onOpenPost(post)
                }
                .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
    }
}

struct HomeHeader: View {
    var onMenu: () -> Void = {}
    var onSearch: () -> Void = {}
    var onMessages: () -> Void = {}
    var onExplore: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            GlassIconButton(systemName: "line.3.horizontal", action: onMenu)
                .accessibilityLabel("Open menu")

            VStack(alignment: .leading, spacing: 3) {
                Text("social.")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Theme.accent)

                Text("CONNECT YOUR WORLD")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(Theme.secondaryText)
            }

            Spacer(minLength: 8)

            GlassIconButton(systemName: "safari", action: onExplore)
            GlassIconButton(systemName: "magnifyingglass", action: onSearch)
            GlassIconButton(systemName: "bubble.left.and.bubble.right.fill", action: onMessages)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppBackground()
        HomeFeedView(
            store: FeedStore(),
            storiesStore: StoriesStore(),
            savedStore: SavedPostsStore(),
            pinnedStore: PinnedPostStore(),
            eventsStore: EventsStore(),
            messagesStore: MessagesStore(),
            commentsStore: CommentsStore()
        )
        BottomTabBar(selection: .constant(.home))
    }
    .preferredColorScheme(.dark)
}
