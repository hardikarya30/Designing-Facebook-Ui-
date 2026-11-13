//
//  AdPreferencesView.swift
//  FacebookUI
//
//  Controls the interests used to personalize ads.
//

import SwiftUI

private struct AdInterest: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let icon: String
}

struct AdPreferencesView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("ads.interests.design") private var designEnabled = true
    @AppStorage("ads.interests.photography") private var photographyEnabled = true
    @AppStorage("ads.interests.travel") private var travelEnabled = true

    @State private var isWhySheetPresented = false

    private let interests = [
        AdInterest(id: "design", title: "Design", subtitle: "Based on pages you follow", icon: "paintpalette"),
        AdInterest(id: "photography", title: "Photography", subtitle: nil, icon: "camera"),
        AdInterest(id: "travel", title: "Travel", subtitle: nil, icon: "mountain.2.fill")
    ]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    Text("We use what you do on social to choose the ads you see. You can turn any of these off.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(hex: "AFC3E3"))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)

                    interestsSection

                    whyRow
                        .padding(.top, -2)

                    Color.clear.frame(height: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isWhySheetPresented) {
            WhyYouSeeThisAdSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                dismiss()
            }
            .accessibilityLabel("Back")

            Spacer()

            Menu {
                Button {
                    isWhySheetPresented = true
                } label: {
                    Label("Why you see this ad", systemImage: "info.circle")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .glassSurface(cornerRadius: 20, tintOpacity: 0.62)
            }
            .accessibilityLabel("More ad preference options")
        }
        .overlay {
            Text("Ad preferences")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1)
                .allowsHitTesting(false)
        }
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR INTERESTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(3)
                .foregroundStyle(Color(hex: "AFC3E3"))
                .padding(.leading, 3)

            VStack(spacing: 0) {
                interestRow(interests[0], isEnabled: $designEnabled)
                divider
                interestRow(interests[1], isEnabled: $photographyEnabled)
                divider
                interestRow(interests[2], isEnabled: $travelEnabled)
            }
            .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.62)
        }
    }

    private func interestRow(_ interest: AdInterest, isEnabled: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: interest.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(hex: "82E8FF"))
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.cyan.opacity(0.1)))
                .overlay {
                    Circle()
                        .strokeBorder(Theme.cyan.opacity(0.15), lineWidth: 1)
                }
                .shadow(color: Theme.cyan.opacity(0.12), radius: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(interest.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                if let subtitle = interest.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "AFC3E3"))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Toggle("Use \(interest.title) for ad personalization", isOn: isEnabled)
                .labelsHidden()
                .tint(Theme.cyan)
                .accessibilityLabel("\(interest.title) interest-based ads")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, interest.subtitle == nil ? 14 : 12)
    }

    private var whyRow: some View {
        Button {
            isWhySheetPresented = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "info.circle")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color(hex: "C8D5EB"))
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Color.white.opacity(0.07)))
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    }

                Text("Why you see this ad")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "9DB7E5"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .glassSurface(cornerRadius: 22, tintOpacity: 0.62)
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 76)
            .padding(.trailing, 14)
    }
}

private struct WhyYouSeeThisAdSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Why you see this ad")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Theme.primaryText)

                    Spacer()

                    GlassIconButton(systemName: "xmark", size: 36) {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }

                Text("Ads may be based on things you do on social, such as the pages you follow and the topics you interact with.")
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "C1D0E9"))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Turning off an interest reduces how much that topic is used to personalize ads. You may still see ads based on other activity or the content you're viewing.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AdPreferencesView()
}
