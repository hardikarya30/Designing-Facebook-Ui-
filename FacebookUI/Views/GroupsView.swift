//
//  GroupsView.swift
//  FacebookUI
//
//  A searchable hub for discovering groups and managing memberships.
//

import SwiftUI

private enum GroupsSection: String, CaseIterable, Identifiable {
    case mine = "My groups"
    case discover = "Discover"

    var id: String { rawValue }
}

struct GroupsView: View {
    var onBack: () -> Void = {}

    @StateObject private var store = GroupsStore()
    @State private var searchText = ""
    @State private var selectedSection: GroupsSection = .discover

    private var visibleGroups: [SocialGroup] {
        let source = selectedSection == .mine
            ? store.groups.filter(store.isJoined)
            : store.groups
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return source }
        return source.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    header
                    searchField
                    sectionPicker

                    if visibleGroups.isEmpty {
                        emptyState
                            .padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 13) {
                            ForEach(visibleGroups) { group in
                                GroupCard(
                                    group: group,
                                    isJoined: store.isJoined(group),
                                    isRequested: store.isRequested(group),
                                    onMembership: { store.toggleMembership(for: group) },
                                    onRequest: { store.toggleRequest(for: group) }
                                )
                            }
                        }
                        .padding(.top, 1)
                    }

                    Color.clear.frame(height: 104)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)

            Text("Groups")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accent)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            GlassIconButton(systemName: "plus", size: 42) {}
                .accessibilityLabel("Create group")
        }
        .padding(.horizontal, 2)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(hex: "B7D4F7"))

            TextField("Search groups", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search groups")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .glassSurface(cornerRadius: 27, tint: Color(hex: "1B355B"), tintOpacity: 0.55)
    }

    private var sectionPicker: some View {
        HStack(spacing: 4) {
            ForEach(GroupsSection.allCases) { section in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedSection = section
                    }
                } label: {
                    Text(section.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selectedSection == section ? .white : Color(hex: "AFC2DF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            if selectedSection == section {
                                Capsule()
                                    .fill(Theme.accent)
                                    .shadow(color: Theme.cyan.opacity(0.55), radius: 9, x: 0, y: 0)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedSection == section ? .isSelected : [])
            }
        }
        .padding(5)
        .glassSurface(cornerRadius: 28, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
    }

    private var emptyState: some View {
        VStack(spacing: 13) {
            Image(systemName: searchText.isEmpty ? "person.3" : "magnifyingglass")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 66, height: 66)
                .background(Circle().fill(Theme.cyan.opacity(0.1)))

            Text(searchText.isEmpty ? "Your groups will live here" : "No groups found")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.primaryText)

            Text(searchText.isEmpty ? "Join a community in Discover." : "Try a different name or search term.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.43)
    }
}

private struct GroupCard: View {
    let group: SocialGroup
    let isJoined: Bool
    let isRequested: Bool
    let onMembership: () -> Void
    let onRequest: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            GroupArtwork(style: group.artwork)
                .frame(height: 98)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .padding(.horizontal, 8)
                .padding(.top, 8)

            HStack(spacing: 12) {
                GroupBadge(group: group)
                    .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("\(group.memberCount) members")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(hex: "A8B8D1"))

                    Label(group.privacy.title, systemImage: group.privacy.symbol)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "9AADC9"))
                }

                Spacer(minLength: 4)
                membershipButton
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
        }
        .background(GlassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.66))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color(hex: "91B5E8", opacity: 0.15), lineWidth: 1)
        }
        .shadow(color: Color(hex: "00040C", opacity: 0.48), radius: 16, x: 0, y: 9)
    }

    @ViewBuilder
    private var membershipButton: some View {
        if isJoined {
            Button(action: onMembership) {
                Text("Leave")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "C6D5EC"))
                    .padding(.horizontal, 17)
                    .frame(height: 42)
                    .background(Capsule().fill(Color.white.opacity(0.07)))
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.13), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Leave \(group.name)")
        } else if group.privacy == .privateGroup {
            Button(action: onRequest) {
                Text(isRequested ? "Requested" : "Request")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: "C5D5EB"))
                    .padding(.horizontal, 17)
                    .frame(height: 42)
                    .background(Capsule().fill(Color(hex: "12243D", opacity: 0.8)))
                    .overlay(Capsule().strokeBorder(Color(hex: "9BB7D8", opacity: 0.18), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isRequested ? "Cancel request to join \(group.name)" : "Request to join \(group.name)")
        } else {
            Button(action: onMembership) {
                Text("Join")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "F7FCFF"))
                    .padding(.horizontal, 21)
                    .frame(height: 42)
                    .background(Capsule().fill(Theme.cyan))
                    .shadow(color: Theme.cyan.opacity(0.48), radius: 10, x: 0, y: 0)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Join \(group.name)")
        }
    }
}

private struct GroupBadge: View {
    let group: SocialGroup

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "101932"))
                .padding(4)
            Circle()
                .strokeBorder(Theme.accentDiagonal, lineWidth: 2)
                .shadow(color: group.tint.opacity(0.72), radius: 8, x: 0, y: 0)

            switch group.artwork {
            case .design:
                ZStack {
                    Circle().stroke(Theme.cyan, lineWidth: 1.7).frame(width: 20, height: 20).offset(x: -5, y: 2)
                    Circle().stroke(Theme.violet, lineWidth: 1.7).frame(width: 20, height: 20).offset(x: 5, y: -2)
                    Circle().stroke(Color(hex: "73A3FF"), lineWidth: 1.7).frame(width: 20, height: 20)
                }
            case .hiking:
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .shadow(color: Theme.cyan.opacity(0.55), radius: 7)
            case .photography:
                Image(systemName: "clapperboard.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: "F06BC6"))
                    .shadow(color: Color(hex: "F06BC6", opacity: 0.65), radius: 7)
            }
        }
    }
}

private struct GroupArtwork: View {
    let style: GroupArtworkStyle

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                switch style {
                case .design:
                    designArtwork(in: proxy.size)
                case .hiking:
                    hikingArtwork(in: proxy.size)
                case .photography:
                    photographyArtwork(in: proxy.size)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private func designArtwork(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "06152E"), Color(hex: "10143D"), Color(hex: "1C1441")],
                startPoint: .leading,
                endPoint: .trailing
            )
            RadialGradient(colors: [Theme.cyan.opacity(0.4), .clear], center: UnitPoint(x: 0.18, y: 0.55), startRadius: 0, endRadius: size.width * 0.38)
            RadialGradient(colors: [Theme.violet.opacity(0.45), .clear], center: UnitPoint(x: 0.52, y: 0.45), startRadius: 0, endRadius: size.width * 0.3)

            HStack(spacing: -size.width * 0.25) {
                ArchOutline()
                    .stroke(Color(hex: "20B9FF"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .shadow(color: Color(hex: "147FFF"), radius: 8)
                    .frame(width: size.width * 0.37, height: size.height * 1.3)
                ArchOutline()
                    .stroke(Color(hex: "B85DFF"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .shadow(color: Color(hex: "A84FFF"), radius: 9)
                    .frame(width: size.width * 0.37, height: size.height * 1.3)
            }
            .offset(x: -size.width * 0.03, y: size.height * 0.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            Text("GOOD\nDESIGN\nBRIGHTER\nPEOPLE")
                .font(.system(size: max(size.height * 0.105, 8), weight: .medium, design: .rounded))
                .tracking(1.2)
                .lineSpacing(1)
                .foregroundStyle(Color(hex: "D8D5FF"))
                .frame(width: size.width * 0.2, alignment: .leading)
                .position(x: size.width * 0.75, y: size.height * 0.5)

            Image(systemName: "leaf.fill")
                .font(.system(size: size.height * 0.48, weight: .regular))
                .foregroundStyle(Color(hex: "081226"))
                .rotationEffect(.degrees(-25))
                .position(x: size.width * 0.94, y: size.height * 0.6)
        }
    }

    private func hikingArtwork(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "F4B79D"), Color(hex: "8A85AB"), Color(hex: "273B59")],
                startPoint: .top,
                endPoint: .bottom
            )
            Circle()
                .fill(Color(hex: "FFD4AE", opacity: 0.7))
                .frame(width: size.height * 0.55, height: size.height * 0.55)
                .blur(radius: 1)
                .position(x: size.width * 0.76, y: size.height * 0.2)

            MountainRange(peakOffset: 0.02)
                .fill(Color(hex: "545B79"))
            MountainRange(peakOffset: 0.16)
                .fill(Color(hex: "303F59"))
            MountainRange(peakOffset: 0.31)
                .fill(LinearGradient(colors: [Color(hex: "23334B"), Color(hex: "101B31")], startPoint: .top, endPoint: .bottom))

            Image(systemName: "figure.hiking")
                .font(.system(size: size.height * 0.7, weight: .medium))
                .foregroundStyle(Color(hex: "101B2A"))
                .shadow(color: .black.opacity(0.35), radius: 3, x: 2, y: 2)
                .position(x: size.width * 0.28, y: size.height * 0.57)

            LinearGradient(colors: [.clear, Color(hex: "091323", opacity: 0.26)], startPoint: .center, endPoint: .bottom)
        }
    }

    private func photographyArtwork(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "18213C"), Color(hex: "393150"), Color(hex: "171C31")], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: "FF9E9A", opacity: 0.55), .clear], center: UnitPoint(x: 0.75, y: 0.5), startRadius: 0, endRadius: size.width * 0.4)

            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array([CGFloat(0.37), 0.61, 0.43, 0.72, 0.54, 0.82, 0.48, 0.66, 0.4, 0.76, 0.5, 0.63, 0.39, 0.7, 0.46].enumerated()), id: \.offset) { index, height in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: index.isMultiple(of: 2) ? "242C48" : "30304D").opacity(0.92))
                        .frame(maxWidth: .infinity)
                        .frame(height: size.height * height)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            HStack(spacing: 0) {
                ForEach(0..<16, id: \.self) { index in
                    Circle()
                        .fill(index.isMultiple(of: 3) ? Color(hex: "FFB58D", opacity: 0.8) : Color(hex: "A4A7FF", opacity: 0.65))
                        .frame(width: index.isMultiple(of: 4) ? 4 : 2, height: index.isMultiple(of: 4) ? 4 : 2)
                        .frame(maxWidth: .infinity)
                        .offset(y: CGFloat(index.isMultiple(of: 2) ? 14 : -4))
                }
            }
            .blur(radius: 2)
            .frame(maxHeight: .infinity, alignment: .bottom)

            CameraIllustration()
                .frame(width: size.width * 0.2, height: size.height * 0.8)
                .position(x: size.width * 0.31, y: size.height * 0.53)
        }
    }
}

private struct ArchOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.55))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * 0.55),
            control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.45)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

private struct MountainRange: Shape {
    var peakOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.12, y: rect.height * (0.58 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width * 0.27, y: rect.height * (0.16 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width * 0.43, y: rect.height * (0.69 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width * 0.58, y: rect.height * (0.3 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width * 0.76, y: rect.height * (0.66 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * (0.42 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * (0.6 + peakOffset)))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct CameraIllustration: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "0A1225"))
                        .frame(width: proxy.size.width * 0.38, height: proxy.size.height * 0.13)
                        .offset(y: 3)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [Color(hex: "161C2D"), Color(hex: "070D19")], startPoint: .top, endPoint: .bottom))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(hex: "8189AA", opacity: 0.65), lineWidth: 1))
                        .overlay {
                            Circle()
                                .fill(Color(hex: "14192B"))
                                .frame(width: proxy.size.width * 0.42, height: proxy.size.width * 0.42)
                                .overlay(Circle().strokeBorder(Color(hex: "77819D"), lineWidth: 2))
                                .overlay(Circle().strokeBorder(Color(hex: "242F4C"), lineWidth: 5).padding(5))
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height * 0.62)
                    Image(systemName: "camera.tripod")
                        .font(.system(size: proxy.size.width * 0.55, weight: .light))
                        .foregroundStyle(Color(hex: "11172A"))
                        .frame(height: proxy.size.height * 0.23)
                }
                .shadow(color: .black.opacity(0.45), radius: 5, x: 2, y: 3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    GroupsView()
}
