//
//  PlanMembersView.swift
//  FacebookUI
//
//  Who shares the plan, what each of them pays, and who has yet to join.
//

import SwiftUI

struct PlanMembersView: View {
    @ObservedObject var store: PlanMembersStore

    let price: Double
    let isYearly: Bool
    let renewalDate: Date
    var accountName: String = "You"
    var onBack: () -> Void = {}

    @State private var isInvitePresented = false
    @State private var resendingName: String?

    private var peopleCount: Int {
        max(store.peopleCount, 1)
    }

    private var priceText: String {
        "£" + price.formatted(.number.precision(.fractionLength(0)))
    }

    private var eachText: String {
        "£" + (price / Double(peopleCount)).formatted(.number.precision(.fractionLength(0)))
    }

    private var priceUnit: String {
        isYearly ? "/ year" : "/ month"
    }

    private var peopleText: String {
        peopleCount == 1 ? "1 person" : "\(peopleCount) people"
    }

    private var renewalText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM"
        return "Renews " + formatter.string(from: renewalDate)
    }

    private var ownerName: String {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "You" : trimmed
    }

    private var ownerInitials: String {
        let letters = ownerName.split(separator: " ").prefix(2).compactMap { $0.first }
        let initials = String(letters).uppercased()
        return initials.isEmpty ? "ME" : initials
    }

    private var resendAlertBinding: Binding<Bool> {
        Binding(
            get: { resendingName != nil },
            set: { isPresented in
                if !isPresented { resendingName = nil }
            }
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    backRow
                    header
                    summaryCard

                    Text("Members")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                        .padding(.leading, 2)
                        .padding(.top, 2)

                    VStack(spacing: 10) {
                        memberRow(
                            name: ownerName,
                            initials: ownerInitials,
                            palette: .cyan,
                            subtitle: "Paid \(eachText) this month",
                            tag: "Paid",
                            tagTint: Theme.cyan,
                            ringed: true
                        )

                        ForEach(store.invited) { invitee in
                            memberRow(
                                name: invitee.name,
                                initials: invitee.initials,
                                palette: invitee.palette,
                                subtitle: "Invited · not joined yet",
                                tag: "Invited",
                                tagTint: Color(hex: "8FA3BF"),
                                ringed: false,
                                resendFor: invitee.name
                            )
                        }
                    }

                    inviteButton

                    Text("Everyone on the plan sees the same 30% & 50% discounts.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "91A8C8"))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isInvitePresented) {
            PlanInviteSheet(store: store)
        }
        .alert("Invite sent again", isPresented: resendAlertBinding) {
            Button("OK", role: .cancel) { resendingName = nil }
        } message: {
            Text("\(resendingName ?? "Your friend") will get a fresh invite to share the plan.")
        }
    }

    private var backRow: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan members")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text("SPLIT WITH FRIENDS")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 8)

            Text(peopleText)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.midnight)
                .padding(.horizontal, 13)
                .frame(height: 32)
                .background(Capsule().fill(Theme.cyan))
                .shadow(color: Theme.cyan.opacity(0.35), radius: 12, y: 5)
                .contentTransition(.numericText())
                .accessibilityLabel(peopleText)
        }
    }

    private var summaryCard: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(priceText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                        .contentTransition(.numericText())

                    Text(priceUnit)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Text("\(eachText) each")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .contentTransition(.numericText())

                Text(renewalText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "8FA3BF"))
            }

            Spacer(minLength: 0)

            Image(systemName: "person.2.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.primaryText.opacity(0.92))
                .frame(width: 62, height: 62)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))
                .overlay {
                    Circle().strokeBorder(Theme.cyan.opacity(0.26), lineWidth: 1)
                }
                .background {
                    Circle()
                        .fill(Theme.cyan.opacity(0.18))
                        .blur(radius: 16)
                }
                .accessibilityHidden(true)
        }
        .padding(16)
        .glassSurface(cornerRadius: 24, tint: Color(hex: "142846"), tintOpacity: 0.72)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: peopleCount)
    }

    private func memberRow(
        name: String,
        initials: String,
        palette: AvatarPalette,
        subtitle: String,
        tag: String,
        tagTint: Color,
        ringed: Bool,
        resendFor: String? = nil
    ) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: initials,
                palette: palette,
                size: 52,
                ringWidth: ringed ? 2 : 0,
                imageName: nil
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 5) {
                Text(tag)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tagTint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(tagTint.opacity(0.16)))
                    .overlay(Capsule().strokeBorder(tagTint.opacity(0.3), lineWidth: 1))

                if let resendFor {
                    Button {
                        resendingName = resendFor
                    } label: {
                        Text("Resend")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.cyan)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Resend the invite to \(resendFor)")
                }
            }
        }
        .padding(12)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
    }

    private var inviteButton: some View {
        Button {
            isInvitePresented = true
        } label: {
            Text("Invite a friend")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Capsule().fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.35), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .accessibilityLabel("Invite a friend")
    }
}

/// Pick friends to share the plan with, with a circular tick on each one chosen.
private struct PlanInviteSheet: View {
    @ObservedObject var store: PlanMembersStore

    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var selectedIDs: Set<String> = []

    private var friends: [InviteFriend] {
        let available = SampleInviteFriends.friends.filter { !store.isInvited($0.id) }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return available }
        return available.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
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
                    if friends.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 0) {
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
                        .glassSurface(cornerRadius: Theme.Radius.card)
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 16)
                    }
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
                Text("Invite a friend")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .accessibilityAddTraits(.isHeader)

                Text("They share the plan with you")
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
                .tint(Theme.cyan)
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
                Text("Send invite")
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
            .accessibilityLabel("Send invite")
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

            Text("No friends to invite")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Everyone here is already on the plan, or nothing matches that name.")
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 26)
    }

    private func send() {
        let picked = SampleInviteFriends.friends.filter { selectedIDs.contains($0.id) }
        guard !picked.isEmpty else { return }
        store.invite(picked)
        dismiss()
    }
}

#Preview {
    PlanMembersView(
        store: PlanMembersStore(),
        price: 250,
        isYearly: false,
        renewalDate: Date(),
        accountName: "Alex Morgan"
    )
}
