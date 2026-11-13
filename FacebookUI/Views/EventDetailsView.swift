//
//  EventDetailsView.swift
//  FacebookUI
//
//  Full event details with a persistent RSVP action bar.
//

import SwiftUI

struct EventDetailsView: View {
    let event: SocialEvent
    let response: EventRSVP?
    let onBack: () -> Void
    let onResponse: (EventRSVP?) -> Void
    let isReminded: Bool
    let reminderDate: Date
    let onToggleReminder: () -> Void

    var authorName: String = "You"
    var isPinned: Bool = false
    var onTogglePin: () -> Void = {}
    var rating: Int = 0
    var onRate: (Int) -> Void = { _ in }
    let messagesStore: MessagesStore
    let feedStore: FeedStore
    let commentsStore: CommentsStore
    let savedStore: SavedPostsStore

    @Environment(\.openURL) private var openURL
    @StateObject private var inviteStore = EventInviteStore()
    @StateObject private var albumStore = EventAlbumStore()
    @State private var isAttendeesPresented = false
    @State private var isInviteSheetPresented = false
    @State private var isAlbumPresented = false
    @State private var hostConversation: Conversation?
    @State private var toastMessage: String?

    private var dateAndTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "EEE d MMM yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_GB")
        timeFormatter.dateFormat = "h:mm a"

        return "\(dateFormatter.string(from: event.date)) · \(timeFormatter.string(from: event.date)) – \(timeFormatter.string(from: event.endDate))"
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 13) {
                    toolbar
                    artwork
                    titleAndDate
                    locationCard
                    hostAndAttendeesCard
                    descriptionCard
                    ratingCard
                    albumRow
                    EventDiscussionSection(event: event, authorName: authorName)
                    Color.clear.frame(height: 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                rsvpControls
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 92)
                    .background {
                        LinearGradient(
                            colors: [Theme.midnight.opacity(0), Theme.midnight.opacity(0.94)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .sheet(isPresented: $isInviteSheetPresented) {
                        InviteFriendsSheet(event: event, store: inviteStore) { friendIDs in
                            inviteStore.send(friendIDs, for: event)
                            showInviteToast(count: friendIDs.count)
                        }
                    }
            }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .top) {
            if let toastMessage {
                Text(toastMessage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassSurface(cornerRadius: 18, shadowed: false)
                    .padding(.top, 56)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $isAttendeesPresented) {
            EventAttendeesSheet(event: event)
        }
        .fullScreenCover(isPresented: $isAlbumPresented) {
            EventAlbumView(event: event, store: albumStore) {
                isAlbumPresented = false
            }
        }
        .fullScreenCover(item: $hostConversation) { conversation in
            ConversationView(
                conversation: conversation,
                store: messagesStore,
                feedStore: feedStore,
                commentsStore: commentsStore,
                savedStore: savedStore
            )
        }
    }

    private func showInviteToast(count: Int) {
        let text = count == 1 ? "Invite sent" : "Invites sent to \(count) friends"

        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            toastMessage = text
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.easeOut(duration: 0.25)) {
                toastMessage = nil
            }
        }
    }

    private var toolbar: some View {
        HStack {
            GlassIconButton(systemName: "arrow.left", size: 42, action: onBack)
                .accessibilityLabel("Back to events")

            Spacer()

            HStack(spacing: 8) {
                GlassIconButton(systemName: isPinned ? "pin.fill" : "pin", size: 42) {
                    onTogglePin()
                }
                .accessibilityLabel(isPinned ? "Unpin from the top of Upcoming" : "Pin to the top of Upcoming")

                GlassIconButton(systemName: "square.and.arrow.up", size: 42) {}
                    .disabled(true)
                    .accessibilityLabel("Share event, coming soon")
            }
        }
    }

    private var artwork: some View {
        ZStack(alignment: .topTrailing) {
            EventsArtwork(style: event.artwork)
                .frame(height: 194)
                .overlay(alignment: .bottomTrailing) {
                    if event.artwork == .rooftopJazz {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 58, weight: .ultraLight))
                            .foregroundStyle(Color.white.opacity(0.14))
                            .padding(.trailing, 82)
                            .padding(.bottom, 20)
                    }
                }

            VStack(spacing: 0) {
                Text(event.date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(Theme.cyan)
                Text(event.date.formatted(.dateTime.day()))
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(event.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Theme.cyan)
            }
            .frame(width: 58, height: 66)
            .background(Color(hex: "08101E", opacity: 0.8), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15).strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        }
        .accessibilityLabel("Illustrated event artwork")
    }

    private var titleAndDate: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(event.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.top, 1)

                Text(dateAndTime)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 3)
    }

    private var locationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 23, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color(hex: "1C3A60")))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))

            VStack(alignment: .leading, spacing: 5) {
                Text(event.location)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(2)
                Text(event.address)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))
                    .lineLimit(1)

                Button(action: openDirections) {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Get directions")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(Theme.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                .accessibilityLabel("Get directions to \(event.location)")
            }

            Spacer(minLength: 0)

            Button(action: openDirections) {
                EventMapPreview()
                    .frame(width: 92, height: 62)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 15).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color(hex: "08101E", opacity: 0.72)))
                            .padding(5)
                    }
            }
            .buttonStyle(MapPressStyle())
            .accessibilityLabel("Open directions to \(event.location) in Maps")
        }
        .padding(11)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.72)
    }

    private var directionsURL: URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: event.address),
            URLQueryItem(name: "q", value: event.location)
        ]
        return components?.url
    }

    private func openDirections() {
        guard let directionsURL else { return }
        openURL(directionsURL)
    }

    private var hostAndAttendeesCard: some View {
        HStack(spacing: 11) {
            AvatarView(
                initials: event.hostInitials,
                palette: event.hostPalette,
                size: 54,
                ringWidth: 2,
                imageName: nil
            )

            VStack(alignment: .leading, spacing: 5) {
                Text("Hosted by \(event.hostName)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
                Button {
                    isAttendeesPresented = true
                } label: {
                    HStack(spacing: 4) {
                        Text("\(event.attendeeCount) people going")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "AFC2DF"))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color(hex: "8FA6C6"))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See who's going to \(event.title)")

                Button {
                    hostConversation = messagesStore.startEventHostConversation(for: event)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Message host")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(Theme.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                .accessibilityLabel("Message \(event.hostName)")
            }

            Spacer(minLength: 4)

            if !event.attendees.isEmpty || event.extraAttendees > 0 {
                attendeeStack
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 11)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.72)
    }

    private var attendeeStack: some View {
        HStack(spacing: -10) {
            ForEach(event.attendees.prefix(3)) { attendee in
                AvatarView(
                    initials: attendee.initials,
                    palette: attendee.palette,
                    size: 36,
                    imageName: nil
                )
                .overlay(Circle().strokeBorder(Theme.midnight, lineWidth: 2))
            }

            Text("+\(event.extraAttendees)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "DDE9F8"))
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color(hex: "152C4B")))
                .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
                .padding(.leading, 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("And \(event.extraAttendees) more attendees")
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(hex: "E2EAF7"))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            if !event.highlights.isEmpty {
                Rectangle()
                    .fill(Theme.hairline)
                    .frame(height: 1)

                HStack(alignment: .top, spacing: 4) {
                    ForEach(event.highlights) { highlight in
                        VStack(spacing: 7) {
                            Image(systemName: highlight.symbol)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color(hex: "DCEBFF"))
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color(hex: "1B3556", opacity: 0.78)))
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))

                            Text(highlight.title)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color(hex: "AFC2DF"))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(13)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.7)
    }

    private var hasEnded: Bool {
        event.endDate < Date()
    }

    @ViewBuilder
    private var ratingCard: some View {
        if hasEnded {
            VStack(alignment: .leading, spacing: 12) {
                Text("How was it?")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.primaryText)

                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                onRate(star)
                            }
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.system(size: 23, weight: .medium))
                                .foregroundStyle(
                                    star <= rating
                                        ? AnyShapeStyle(Theme.accent)
                                        : AnyShapeStyle(Color.white.opacity(0.24))
                                )
                                .frame(width: 42, height: 42)
                                .background(Circle().fill(Color.white.opacity(star <= rating ? 0.06 : 0.04)))
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                                .scaleEffect(star <= rating ? 1 : 0.94)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Rate \(star) out of 5")
                        .accessibilityAddTraits(star == rating ? .isSelected : [])
                    }
                }

                if rating > 0 {
                    Text("Thanks — your rating was saved.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.cyan)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.7)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
        }
    }

    private var albumRow: some View {
        let photos = albumStore.photos(for: event)

        return Button {
            isAlbumPresented = true
        } label: {
            HStack(spacing: 12) {
                albumThumbnails(photos)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Event album")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text(photos.isEmpty ? "No photos yet" : "\(photos.count) photos")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open the event album, \(photos.count) photos")
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.7)
    }

    @ViewBuilder
    private func albumThumbnails(_ photos: [EventAlbumPhoto]) -> some View {
        if photos.isEmpty {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 52, height: 46)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.cyan.opacity(0.12)))
        } else {
            ZStack(alignment: .leading) {
                ForEach(Array(photos.prefix(3).enumerated()), id: \.element.id) { index, photo in
                    albumThumbnail(photo)
                        .offset(x: CGFloat(index) * 17)
                        .zIndex(Double(3 - index))
                }
            }
            .frame(width: 80, height: 44, alignment: .leading)
        }
    }

    private func albumThumbnail(_ photo: EventAlbumPhoto) -> some View {
        ZStack {
            if let imageName = photo.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: photo.media.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: photo.symbol)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.86))
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Theme.midnight, lineWidth: 2)
        }
    }

    private var rsvpControls: some View {
        VStack(spacing: 9) {
            HStack(spacing: 10) {
                ForEach(EventRSVP.allCases) { choice in
                    rsvpButton(choice)
                }
            }

            HStack(spacing: 10) {
                inviteButton
                reminderButton
            }

            if isReminded {
                Text("We'll nudge you the evening before · \(reminderDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.8), value: isReminded)
    }

    private var inviteButton: some View {
        Button {
            isInviteSheetPresented = true
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 15, weight: .semibold))
                Text("Invite")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Color(hex: "D7E3F5"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Invite friends to \(event.title)")
    }

    private var reminderButton: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                onToggleReminder()
            }
        } label: {
            Image(systemName: isReminded ? "bell.fill" : "bell")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isReminded ? Theme.midnight : Color(hex: "D7E3F5"))
                .frame(width: 58, height: 54)
                .background {
                    if isReminded {
                        Capsule().fill(Theme.accent)
                    } else {
                        Capsule().fill(Color(hex: "10213A", opacity: 0.96))
                    }
                }
                .overlay(Capsule().strokeBorder(isReminded ? Color.white.opacity(0.18) : Color.white.opacity(0.11), lineWidth: 1))
                .shadow(color: isReminded ? Theme.cyan.opacity(0.24) : .clear, radius: 14, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isReminded ? .isSelected : [])
        .accessibilityLabel(isReminded ? "Turn off the reminder for \(event.title)" : "Remind me about \(event.title)")
    }

    private func rsvpButton(_ choice: EventRSVP) -> some View {
        let isSelected = response == choice
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                onResponse(isSelected ? nil : choice)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark" : choice.symbol)
                    .font(.system(size: 16, weight: .semibold))
                Text(choice.title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.white : Color(hex: "D7E3F5"))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background {
                if isSelected {
                    Capsule().fill(choice == .going ? Theme.accent : LinearGradient(colors: [Theme.violet, Color(hex: "7364C5")], startPoint: .leading, endPoint: .trailing))
                } else {
                    Capsule().fill(Color(hex: "10213A", opacity: 0.96))
                }
            }
            .overlay(Capsule().strokeBorder(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.11), lineWidth: 1))
            .shadow(color: isSelected ? Theme.cyan.opacity(0.24) : .clear, radius: 14, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(choice.title) for \(event.title)")
    }
}

private struct MapPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

private struct EventMapPreview: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [Color(hex: "213A5D"), Color(hex: "132743")], startPoint: .topLeading, endPoint: .bottomTrailing)

                EventMapRoads()
                    .stroke(Color(hex: "7891B3", opacity: 0.25), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                EventMapRoads()
                    .stroke(Color(hex: "AFBED4", opacity: 0.2), style: StrokeStyle(lineWidth: 0.7, lineCap: .round, dash: [2, 4]))

                Circle()
                    .fill(Theme.cyan.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .blur(radius: 7)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                    .shadow(color: Theme.cyan.opacity(0.65), radius: 7)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
}

private struct EventMapRoads: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.12, y: rect.height * 1.05))
        path.addCurve(to: CGPoint(x: rect.width * 0.5, y: rect.height * -0.05), control1: CGPoint(x: rect.width * 0.45, y: rect.height * 0.72), control2: CGPoint(x: rect.width * 0.22, y: rect.height * 0.32))
        path.move(to: CGPoint(x: rect.width * 0.72, y: rect.height * 1.08))
        path.addCurve(to: CGPoint(x: rect.width * 1.04, y: rect.height * 0.18), control1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.63), control2: CGPoint(x: rect.width * 0.95, y: rect.height * 0.47))
        path.move(to: CGPoint(x: rect.width * -0.1, y: rect.height * 0.42))
        path.addLine(to: CGPoint(x: rect.width * 1.08, y: rect.height * 0.72))
        return path
    }
}

#Preview {
    EventDetailsView(
        event: SampleEvents.events[0],
        response: .going,
        onBack: {},
        onResponse: { _ in },
        isReminded: true,
        reminderDate: Date(),
        onToggleReminder: {},
        messagesStore: MessagesStore(),
        feedStore: FeedStore(),
        commentsStore: CommentsStore(),
        savedStore: SavedPostsStore()
    )
}
