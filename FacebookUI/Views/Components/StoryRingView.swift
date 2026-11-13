//
//  StoryRingView.swift
//  FacebookUI
//

import SwiftUI

struct StoryRingView: View {
    let story: Story
    var hasStory: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [story.palette.colors[0], Theme.cyan, story.palette.colors[1]],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 68, height: 68)

                if story.isMine {
                    if hasStory {
                        AvatarView(
                            initials: story.initials,
                            palette: story.palette,
                            size: 58
                        )
                    } else {
                        Circle()
                            .fill(Theme.deepBlue.opacity(0.45))
                            .frame(width: 58, height: 58)
                            .overlay {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Theme.cyan)
                            }
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            }
                    }
                } else {
                    AvatarView(
                        initials: story.initials,
                        palette: story.palette,
                        size: 58
                    )
                }
            }
            .frame(width: 68, height: 68)

            Text(story.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(story.isMine ? Theme.primaryText.opacity(0.9) : Theme.secondaryText)
                .lineLimit(1)
        }
        .frame(width: 74)
    }
}

#Preview {
    HStack(spacing: 10) {
        ForEach(SampleFeed.stories) { story in
            StoryRingView(story: story)
        }
    }
    .padding()
    .background(AppBackground())
}
