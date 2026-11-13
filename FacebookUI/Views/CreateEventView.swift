//
//  CreateEventView.swift
//  FacebookUI
//
//  Form for creating and publishing a local event.
//

import SwiftUI

private enum CreateEventPicker: String, Identifiable {
    case date
    case time

    var id: String { rawValue }
}

struct CreateEventView: View {
    let hostName: String
    let onBack: () -> Void
    let onCreate: (SocialEvent) -> Void

    @State private var title = ""
    @State private var eventDate = Calendar.current.date(
        byAdding: .day,
        value: 7,
        to: Calendar.current.startOfDay(for: Date())
    ) ?? Date()
    @State private var startTime = Calendar.current.date(
        bySettingHour: 18,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()
    @State private var location = ""
    @State private var eventDescription = ""
    @State private var activePicker: CreateEventPicker?
    @State private var validationMessage: String?

    private var formattedDate: String {
        eventDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
    }

    private var formattedTime: String {
        startTime.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 11) {
                    header
                    coverPlaceholder
                    eventNameField
                    dateRow
                    timeRow
                    locationField
                    descriptionField
                    visibilityRow
                    Color.clear.frame(height: 12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                createButton
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activePicker) { picker in
            CreateEventPickerSheet(
                picker: picker,
                eventDate: $eventDate,
                startTime: $startTime
            )
        }
    }

    private var header: some View {
        ZStack {
            Text("Create event")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            HStack {
                GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                    .accessibilityLabel("Back to events")
                Spacer()
            }
        }
        .frame(height: 48)
    }

    private var coverPlaceholder: some View {
        ZStack {
            EventsArtwork(style: .rooftopJazz)
            LinearGradient(
                colors: [Color(hex: "07132B", opacity: 0.1), Color(hex: "07132B", opacity: 0.42)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 10) {
                Image(systemName: "photo")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .glassSurface(cornerRadius: 28, tint: Color(hex: "18345F"), tintOpacity: 0.65)

                Text("Add cover")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(height: 38)
                    .glassSurface(cornerRadius: 22, tint: Color(hex: "18345F"), tintOpacity: 0.68)
            }
        }
        .frame(height: 166)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Illustrated cover placeholder")
    }

    private var eventNameField: some View {
        HStack(spacing: 14) {
            fieldIcon("textformat")
            VStack(alignment: .leading, spacing: 4) {
                Text("Event name")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "91A8C8"))
                TextField("Add an event name", text: $title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .tint(Theme.cyan)
                    .accessibilityLabel("Event name")
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 82)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.73)
    }

    private var dateRow: some View {
        Button {
            activePicker = .date
        } label: {
            HStack(spacing: 14) {
                fieldIcon("calendar")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "91A8C8"))
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.primaryText)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "91A8C8"))
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 82)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.73)
        .accessibilityLabel("Date, \(formattedDate)")
    }

    private var timeRow: some View {
        Button {
            activePicker = .time
        } label: {
            HStack(spacing: 14) {
                fieldIcon("clock")
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start time")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "91A8C8"))
                    Text(formattedTime)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.primaryText)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "91A8C8"))
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 82)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.73)
        .accessibilityLabel("Start time, \(formattedTime)")
    }

    private var locationField: some View {
        HStack(spacing: 14) {
            fieldIcon("mappin.and.ellipse")
            VStack(alignment: .leading, spacing: 4) {
                Text("Location")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "91A8C8"))
                TextField("Add a location", text: $location)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .tint(Theme.cyan)
                    .accessibilityLabel("Location")
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "91A8C8"))
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 82)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.73)
    }

    private var descriptionField: some View {
        HStack(alignment: .top, spacing: 14) {
            fieldIcon("doc.text")
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 5) {
                Text("Description")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "91A8C8"))

                ZStack(alignment: .topLeading) {
                    if eventDescription.isEmpty {
                        Text("Add a few details about your event")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(hex: "7F96B6"))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $eventDescription)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.primaryText)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 78)
                        .tint(Theme.cyan)
                        .accessibilityLabel("Description")
                }
            }
        }
        .padding(14)
        .frame(minHeight: 120, alignment: .topLeading)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.73)
    }

    private var visibilityRow: some View {
        HStack(spacing: 14) {
            fieldIcon("person.2")
            VStack(alignment: .leading, spacing: 4) {
                Text("Visibility")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "91A8C8"))
                Text("Friends")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "91A8C8"))
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 82)
        .glassSurface(cornerRadius: 21, tint: Color(hex: "142846"), tintOpacity: 0.73)
        .accessibilityElement(children: .combine)
    }

    private var createButton: some View {
        VStack(spacing: 8) {
            if let validationMessage {
                Text(validationMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "FF829E"))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isStaticText)
            }

            Button(action: createEvent) {
                Text("Create event")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Theme.accent, in: Capsule())
                    .shadow(color: Theme.cyan.opacity(0.28), radius: 16, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background {
            LinearGradient(
                colors: [Theme.midnight.opacity(0.02), Theme.midnight.opacity(0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func fieldIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color(hex: "BDD0EC"))
            .frame(width: 46, height: 46)
            .background(Circle().fill(Color(hex: "10233D", opacity: 0.88)))
    }

    private func createEvent() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = eventDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedLocation.isEmpty, !trimmedDescription.isEmpty else {
            validationMessage = "Add an event name, location, and description to continue."
            return
        }

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: eventDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        let startDate = calendar.date(from: dateComponents) ?? eventDate
        guard startDate > Date() else {
            validationMessage = "Choose a future date and time."
            return
        }

        let resolvedHostName = hostName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "You" : hostName
        let hostInitials = resolvedHostName
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()

        let event = SocialEvent(
            id: UUID().uuidString,
            title: trimmedTitle,
            date: startDate,
            endDate: startDate.addingTimeInterval(3 * 60 * 60),
            location: trimmedLocation,
            address: trimmedLocation,
            hostName: resolvedHostName,
            hostInitials: hostInitials.isEmpty ? "Y" : hostInitials,
            hostPalette: .cyan,
            attendeeCount: 0,
            attendees: [],
            extraAttendees: 0,
            description: trimmedDescription,
            highlights: [],
            artwork: .rooftopJazz,
            isInvitation: false,
            inviter: nil
        )

        onCreate(event)
    }
}

private struct CreateEventPickerSheet: View {
    let picker: CreateEventPicker
    @Binding var eventDate: Date
    @Binding var startTime: Date

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(picker == .date ? "Choose date" : "Start time")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.cyan)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            if picker == .date {
                DatePicker("Event date", selection: $eventDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Theme.cyan)
                    .labelsHidden()
                    .padding(.horizontal, 12)
                Spacer(minLength: 0)
            } else {
                DatePicker("Start time", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(Theme.cyan)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppBackground())
        .presentationDetents(picker == .date ? [.height(470)] : [.medium])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    CreateEventView(hostName: "Hardik Arya Arya", onBack: {}, onCreate: { _ in })
}
