//
//  InviteFriendsSheet.swift
//  FacebookUI
//
//  Pick friends to invite to an event, with a remembered selection per event.
//

import SwiftUI

struct InviteFriendsSheet: View {
    let event: SocialEvent

    @ObservedObject var store: EventInviteStore
    var onSend: (Set<String>) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selectedIDs: Set<String>

    init(event: SocialEvent, store: EventInviteStore, onSend: @escaping (Set<String>) -> Void) {
        self.event = event
        self.store = store
        self.onSend = onSend
        _selectedIDs = State(initialValue: store.invitedIDs(for: event))
    }

    private var friends: [InviteFriend] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return SampleInviteFriends.friends }
        return SampleInviteFriends.friends.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var eventLine: String {
        let day = event.date.formatted(.dateTime.weekday(.wide))
        let time = event.date.formatted(date: .omitted, time: .shortened)
        return "\(event.title) · \(day) \(time)"
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header
                searchField
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if friends.isEmpty {
                            emptyState
                        } else {
                            ForEach(Array(friends.enumerated()), id: \.element.id) { index, friend in
                                row(friend)

                                if index < friends.count - 1 {
                                    Rectangle()
                                        .fill(Theme.hairline)
                                        .frame(height: 1)
                                        .padding(.leading, 70)
                                }
                            }
                        }
                    }
                    .glassSurface(cornerRadius: Theme.Radius.card)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 16)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footer
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Invite friends")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .accessibilityAddTraits(.isHeader)

                Text(eventLine)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            GlassIconButton(systemName: "xmark", size: 36) {
                dismiss()
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search friends", text: $query)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search friends")

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 46)
        .glassSurface(cornerRadius: 23, tint: Color(hex: "1B355B"), tintOpacity: 0.55, shadowed: false)
    }

    private func row(_ friend: InviteFriend) -> some View {
        let isSelected = selectedIDs.contains(friend.id)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if isSelected {
                    selectedIDs.remove(friend.id)
                } else {
                    selectedIDs.insert(friend.id)
                }
            }
        } label: {
            HStack(spacing: 12) {
                AvatarView(
                    initials: friend.initials,
                    palette: friend.palette,
                    size: 42,
                    imageName: nil
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(friend.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)

                    Text("\(friend.mutualFriends) mutual friends")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.clear : Color.white.opacity(0.28),
                            lineWidth: 1.4
                        )
                        .frame(width: 28, height: 28)

                    if isSelected {
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.midnight)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(friend.name), \(friend.mutualFriends) mutual friends")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Text(selectionText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .lineLimit(1)

            Spacer(minLength: 8)

            Button(action: send) {
                Text("Send invites")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedIDs.isEmpty ? Theme.tertiaryText : Theme.midnight)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background {
                        if selectedIDs.isEmpty {
                            Capsule().fill(Color.white.opacity(0.07))
                        } else {
                            Capsule().fill(Theme.accent)
                        }
                    }
                    .shadow(color: selectedIDs.isEmpty ? .clear : Theme.cyan.opacity(0.32), radius: 14, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(selectedIDs.isEmpty)
            .accessibilityLabel("Send invites")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            LinearGradient(
                colors: [Theme.midnight.opacity(0), Theme.midnight.opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var selectionText: String {
        switch selectedIDs.count {
        case 0: return "No friends selected"
        case 1: return "1 friend selected"
        default: return "\(selectedIDs.count) friends selected"
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Theme.cyan)

            Text("No friends match this search")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Try another name.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
    }

    private func send() {
        guard !selectedIDs.isEmpty else { return }
        onSend(selectedIDs)
        dismiss()
    }
}

#Preview {
    InviteFriendsSheet(event: SampleEvents.events[0], store: EventInviteStore(), onSend: { _ in })
}
