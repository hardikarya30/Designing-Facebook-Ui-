//
//  AddVenueView.swift
//  FacebookUI
//
//  Save a place of your own beside the venues from your events.
//

import SwiftUI

struct AddVenueView: View {
    @ObservedObject var store: SavedVenuesStore

    var onBack: () -> Void = {}

    @State private var name = ""
    @State private var area = ""
    @State private var address = ""
    @State private var showsErrors = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedArea: String {
        area.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedAddress: String {
        address.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var errorText: String? {
        guard showsErrors else { return nil }
        if trimmedName.isEmpty { return "Add a venue name to save it." }
        if trimmedArea.isEmpty { return "Add the area the venue is in." }
        if trimmedAddress.isEmpty { return "Add the venue's address." }
        return nil
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    backRow
                    title

                    fieldsCard

                    if let errorText {
                        Text(errorText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.rose)
                            .padding(.leading, 4)
                            .transition(.opacity)
                    }

                    hintRow

                    addButton

                    Text("You can edit or remove it later.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "8FA3BF"))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.2), value: errorText)
    }

    private var backRow: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back to saved venues")

            Spacer(minLength: 0)
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Add venue")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accent)
                .accessibilityAddTraits(.isHeader)

            Text("YOUR OWN PLACE")
                .font(.system(size: 9, weight: .semibold))
                .tracking(3.1)
                .foregroundStyle(Color(hex: "91A8C8"))
        }
        .padding(.bottom, 2)
    }

    private var fieldsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            field("Venue name", text: $name, placeholder: "The Copper Kettle", isEmpty: trimmedName.isEmpty)
                .padding(.bottom, 12)

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            field("Area", text: $area, placeholder: "North Cheam", isEmpty: trimmedArea.isEmpty)
                .padding(.vertical, 12)

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            field("Address", text: $address, placeholder: "812 London Road, North Cheam, SM3 9BJ", isEmpty: trimmedAddress.isEmpty, isMultiline: true)
                .padding(.top, 12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassSurface(cornerRadius: 24, tint: Color(hex: "142846"), tintOpacity: 0.7)
    }

    private func field(
        _ label: String,
        text: Binding<String>,
        placeholder: String,
        isEmpty: Bool,
        isMultiline: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(showsErrors && isEmpty ? Theme.rose : Color(hex: "AFC2DF"))

            TextField(placeholder, text: text, axis: isMultiline ? .vertical : .horizontal)
                .textFieldStyle(.plain)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .lineLimit(isMultiline ? 1...3 : 1...1)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .accessibilityLabel(label)
        }
    }

    private var hintRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.primaryText.opacity(0.9))

            Text("It will be pinned near your home address.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
    }

    private var addButton: some View {
        Button(action: addVenue) {
            Text("Add venue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Capsule().fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.35), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
        .accessibilityLabel("Add venue")
    }

    private func addVenue() {
        guard !trimmedName.isEmpty, !trimmedArea.isEmpty, !trimmedAddress.isEmpty else {
            withAnimation(.easeInOut(duration: 0.2)) {
                showsErrors = true
            }
            return
        }

        showsErrors = false
        store.addVenue(name: trimmedName, area: trimmedArea, address: trimmedAddress)
        onBack()
    }
}

#Preview {
    AddVenueView(store: SavedVenuesStore())
}
