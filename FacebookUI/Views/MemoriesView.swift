//
//  MemoriesView.swift
//  FacebookUI
//
//  Anniversary memories from sample and user-authored posts.
//

import SwiftUI

struct MemoriesView: View {
    @ObservedObject var store: MemoriesStore
    @ObservedObject var feedStore: FeedStore
    var onBack: () -> Void = {}

    @State private var selectedMemory: Memory?

    private var memoriesForToday: [Memory] {
        let calendar = Calendar.current
        let today = Date()
        let ownPosts = feedStore.publishedPosts.filter(feedStore.isMine)
        let userMemories = ownPosts.compactMap { post -> Memory? in
            guard post.createdAt < today,
                  calendar.component(.month, from: post.createdAt) == calendar.component(.month, from: today),
                  calendar.component(.day, from: post.createdAt) == calendar.component(.day, from: today),
                  (calendar.dateComponents([.year], from: post.createdAt, to: today).year ?? 0) > 0 else {
                return nil
            }
            return Memory(post: post, artwork: artworkStyle(for: post))
        }

        return (SampleMemories.posts.filter { isAnniversary($0.date, on: today, calendar: calendar) } + userMemories)
            .sorted { $0.date > $1.date }
    }

    private var featuredMemory: Memory? {
        memoriesForToday.first(where: \.isFeatured) ?? memoriesForToday.first
    }

    private var moreMemories: [Memory] {
        memoriesForToday
            .filter { $0.id != featuredMemory?.id }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    if let featuredMemory {
                        Text("On this day")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.primaryText)
                            .padding(.top, 4)

                        featuredCard(featuredMemory)

                        if !moreMemories.isEmpty {
                            Text("More memories")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Theme.primaryText)
                                .padding(.top, 1)

                            VStack(spacing: 12) {
                                ForEach(moreMemories) { memory in
                                    Button {
                                        selectedMemory = memory
                                    } label: {
                                        moreMemoryRow(memory)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Open memory: \(memory.caption)")
                                }
                            }
                        }
                    } else {
                        emptyState
                            .padding(.top, 42)
                    }

                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedMemory) { memory in
            MemoryDetailSheet(
                memory: memory,
                store: store
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer()

            Text("Memories")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Spacer()

            Color.clear.frame(width: 42, height: 42)
        }
        .padding(.bottom, 12)
    }

    private func featuredCard(_ memory: Memory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            MemoriesArtwork(style: memory.artwork)
                .frame(height: 164)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            Text(ageLabel(for: memory, withToday: true))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "A8B9D4"))

            Text(memory.caption)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                shareButton(for: memory)
                saveButton(for: memory)
            }
            .padding(.top, 3)
        }
        .padding(11)
        .glassSurface(cornerRadius: 25, tint: Color(hex: "142846"), tintOpacity: 0.72)
    }

    private func moreMemoryRow(_ memory: Memory) -> some View {
        HStack(spacing: 12) {
            MemoriesArtwork(style: memory.artwork)
                .frame(width: 74, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(ageLabel(for: memory, withToday: false))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "A8B9D4"))
                Text(memory.caption)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: "9CB3D4"))
        }
        .padding(10)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.67)
    }

    private var emptyState: some View {
        VStack(spacing: 13) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 29, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 68, height: 68)
                .background(Circle().fill(Theme.cyan.opacity(0.11)))

            Text("No memories today")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text("Posts you shared on this day in past years will appear here.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.46)
    }

    private func shareButton(for memory: Memory) -> some View {
        ShareLink(item: memory.caption) {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .glassSurface(cornerRadius: 23, tint: Color(hex: "1A3559"), tintOpacity: 0.68)
        }
        .buttonStyle(.plain)
    }

    private func saveButton(for memory: Memory) -> some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                store.toggleSaved(memory)
            }
        } label: {
            Label(store.isSaved(memory) ? "Saved" : "Save", systemImage: store.isSaved(memory) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(store.isSaved(memory) ? Theme.cyan : Theme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .glassSurface(cornerRadius: 23, tint: Color(hex: "1A3559"), tintOpacity: 0.68)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(store.isSaved(memory) ? "Remove saved memory" : "Save memory")
    }

    private func ageLabel(for memory: Memory, withToday: Bool) -> String {
        let years = Calendar.current.dateComponents([.year], from: memory.date, to: Date()).year ?? 0
        if withToday {
            if years == 1 { return "1 year ago today" }
            return "\(years) years ago today"
        }
        if years == 1 { return "Last year" }
        return "\(years) years ago"
    }

    private func isAnniversary(_ date: Date, on today: Date, calendar: Calendar) -> Bool {
        calendar.component(.month, from: date) == calendar.component(.month, from: today)
            && calendar.component(.day, from: date) == calendar.component(.day, from: today)
            && (calendar.dateComponents([.year], from: date, to: today).year ?? 0) > 0
    }

    private func artworkStyle(for post: Post) -> MemoryArtworkStyle {
        switch post.media {
        case .dusk: return .city
        case .ocean: return .coast
        case .aurora: return .road
        }
    }
}

private struct MemoryDetailSheet: View {
    let memory: Memory
    @ObservedObject var store: MemoriesStore

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 17) {
                    ZStack(alignment: .topTrailing) {
                        MemoriesArtwork(style: memory.artwork)
                            .frame(height: 270)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                        GlassIconButton(systemName: "xmark", size: 38) { dismiss() }
                            .accessibilityLabel("Close memory")
                            .padding(12)
                    }

                    Text(ageLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(hex: "A8B9D4"))

                    Text(memory.caption)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        ShareLink(item: memory.caption) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .glassSurface(cornerRadius: 24, tint: Color(hex: "1A3559"), tintOpacity: 0.68)
                        }
                        .buttonStyle(.plain)

                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                                store.toggleSaved(memory)
                            }
                        } label: {
                            Label(store.isSaved(memory) ? "Saved" : "Save", systemImage: store.isSaved(memory) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(store.isSaved(memory) ? Theme.cyan : Theme.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .glassSurface(cornerRadius: 24, tint: Color(hex: "1A3559"), tintOpacity: 0.68)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var ageLabel: String {
        let years = Calendar.current.dateComponents([.year], from: memory.date, to: Date()).year ?? 0
        return years == 1 ? "1 year ago today" : "\(years) years ago today"
    }
}

#Preview {
    MemoriesView(store: MemoriesStore(), feedStore: FeedStore())
}
