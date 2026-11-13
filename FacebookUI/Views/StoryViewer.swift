//
//  StoryViewer.swift
//  FacebookUI
//
//  A full-screen viewer for the stories row: five-second slides, tap to
//  move, hold to pause, and a heart that floats up from the reaction bar.
//

import SwiftUI

struct StoryViewer: View {
    let stories: [Story]

    @State private var index: Int
    @State private var progress: CGFloat = 0
    @State private var isPaused = false
    @State private var timerTask: Task<Void, Never>?

    @State private var reply = ""
    @FocusState private var isReplyFocused: Bool
    @State private var isViewersPresented = false

    @State private var heartOffset: CGFloat = 0
    @State private var heartOpacity: Double = 0
    @State private var heartScale: CGFloat = 0.6

    @Environment(\.dismiss) private var dismiss

    init(stories: [Story], startID: String) {
        self.stories = stories
        let start = stories.firstIndex { $0.id == startID } ?? 0
        _index = State(initialValue: start)
    }

    private var story: Story {
        stories[min(index, stories.count - 1)]
    }

    var body: some View {
        ZStack {
            AppBackground()

            art

            tapZones

            VStack(spacing: 0) {
                progressBars
                header
                Spacer(minLength: 0)
                captionCard
                reactionBar
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)

            risingHeart
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timerTask?.cancel()
        }
        .onChange(of: index) { _, _ in
            startTimer()
        }
        .onChange(of: isViewersPresented) { _, showing in
            isPaused = showing
        }
        .sheet(isPresented: $isViewersPresented) {
            StoryViewersSheet()
        }
    }

    // MARK: - Artwork

    private var art: some View {
        ZStack {
            if let imageName = story.imageName {
                Color.clear
                    .overlay {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                LinearGradient(
                    colors: story.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(story.media.glow.opacity(0.28))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .offset(x: -60, y: -80)

                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: 100, y: 90)

                Image(systemName: story.symbol)
                    .font(.system(size: 128, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .shadow(color: story.media.glow.opacity(0.6), radius: 30)
            }

            LinearGradient(
                colors: [Color.black.opacity(0.4), Color.clear, Color.black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: index)
    }

    // MARK: - Tap to move, hold to pause

    private var tapZones: some View {
        HStack(spacing: 0) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { goBack() }

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { goForward() }
        }
        .ignoresSafeArea()
        .onLongPressGesture(minimumDuration: 0.18, perform: {}, onPressingChanged: { pressing in
            isPaused = pressing
        })
    }

    // MARK: - Progress

    private var progressBars: some View {
        HStack(spacing: 4) {
            ForEach(stories.indices, id: \.self) { slot in
                Capsule()
                    .fill(Color.white.opacity(0.27))
                    .frame(height: 3)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Color.white)
                            .scaleEffect(x: fill(for: slot), anchor: .leading)
                    }
            }
        }
    }

    private func fill(for slot: Int) -> CGFloat {
        if slot < index { return 1 }
        if slot == index { return progress }
        return 0
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            AvatarView(
                initials: story.initials,
                palette: story.palette,
                size: 34,
                ringWidth: 2
            )

            VStack(alignment: .leading, spacing: 1) {
                Text(story.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(story.time)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer(minLength: 8)

            if story.isMine {
                GlassIconButton(systemName: "eye", size: 36) {
                    isViewersPresented = true
                }
                .accessibilityLabel("See who viewed your story")
            }

            GlassIconButton(systemName: "xmark", size: 36) {
                dismiss()
            }
            .accessibilityLabel("Close story")
        }
        .padding(.top, 12)
    }

    // MARK: - Caption

    private var captionCard: some View {
        Text(story.caption)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white.opacity(0.92))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassSurface(cornerRadius: 20, tint: Theme.deepBlue, tintOpacity: 0.35, shadowed: false)
            .padding(.bottom, 12)
    }

    // MARK: - Reaction bar

    private var reactionBar: some View {
        HStack(spacing: 8) {
            Button(action: burstHeart) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.rose)
                    .frame(width: 40, height: 40)
                    .glassSurface(cornerRadius: 20)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Send a heart")

            TextField("Reply to \(story.name)…", text: $reply)
                .font(.subheadline)
                .foregroundStyle(.white)
                .tint(Theme.cyan)
                .focused($isReplyFocused)
                .submitLabel(.send)
                .onSubmit {
                    reply = ""
                    isReplyFocused = false
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glassSurface(cornerRadius: 20, tint: Theme.deepBlue, tintOpacity: 0.4, shadowed: false)

            ShareLink(item: "\(story.name) on social: \(story.caption)") {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 40, height: 40)
                    .glassSurface(cornerRadius: 20)
            }
            .accessibilityLabel("Share story")
        }
    }

    // MARK: - Rising heart

    private var risingHeart: some View {
        VStack {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 46))
                .foregroundStyle(Theme.rose)
                .shadow(color: Theme.rose.opacity(0.65), radius: 18)
                .scaleEffect(heartScale)
                .offset(y: heartOffset)
                .opacity(heartOpacity)
                .padding(.bottom, 96)
        }
        .allowsHitTesting(false)
    }

    private func burstHeart() {
        heartScale = 0.6
        heartOffset = 0
        heartOpacity = 1

        withAnimation(.easeOut(duration: 0.9)) {
            heartOffset = -320
            heartOpacity = 0
            heartScale = 1.35
        }
    }

    // MARK: - Playback

    private func startTimer() {
        timerTask?.cancel()
        progress = 0

        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(33))
                if Task.isCancelled { return }

                if isPaused { continue }

                progress = min(1, progress + 0.033 / 5)

                if progress >= 1 { break }
            }

            if !Task.isCancelled {
                goForward()
            }
        }
    }

    private func goForward() {
        if index < stories.count - 1 {
            index += 1
        } else {
            dismiss()
        }
    }

    private func goBack() {
        if index > 0 {
            index -= 1
        } else {
            startTimer()
        }
    }
}

#Preview {
    StoryViewer(stories: Array(SampleFeed.stories.dropFirst()), startID: "alex")
}
