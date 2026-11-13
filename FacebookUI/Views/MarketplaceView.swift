//
//  MarketplaceView.swift
//  FacebookUI
//
//  Browse, search and save nearby Marketplace listings.
//

import SwiftUI

struct MarketplaceView: View {
    @ObservedObject var store: MarketplaceStore
    var onOpenMessages: () -> Void = {}
    var onMessageSeller: (MarketplaceListing) -> Void = { _ in }

    @State private var searchText = ""
    @State private var selectedCategory: MarketplaceCategory = .forYou
    @State private var selectedListing: MarketplaceListing?
    @State private var pendingSellerMessage: MarketplaceListing?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var visibleListings: [MarketplaceListing] {
        store.listings.filter { listing in
            let matchesCategory = selectedCategory == .forYou || listing.category == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty
                || listing.title.localizedCaseInsensitiveContains(query)
                || listing.description.localizedCaseInsensitiveContains(query)
                || listing.category.title.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchField
                    categories

                    if visibleListings.isEmpty {
                        emptyState
                            .padding(.top, 20)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(visibleListings) { listing in
                                MarketplaceListingCard(
                                    listing: listing,
                                    isSaved: store.isSaved(listing),
                                    onOpen: { selectedListing = listing },
                                    onToggleSaved: { store.toggleSaved(listing) }
                                )
                            }
                        }
                        .padding(.top, 1)
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedListing, onDismiss: {
            guard let listing = pendingSellerMessage else { return }
            pendingSellerMessage = nil
            onMessageSeller(listing)
        }) { listing in
            MarketplaceListingDetail(
                listing: listing,
                isSaved: store.isSaved(listing),
                onToggleSaved: { store.toggleSaved(listing) },
                onMessageSeller: {
                    pendingSellerMessage = listing
                    selectedListing = nil
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Marketplace")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .accessibilityAddTraits(.isHeader)

                HStack(spacing: 7) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14, weight: .medium))
                    Text("London")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.leading, 1)
                }
                .foregroundStyle(Color(hex: "AEBFDA"))
            }

            Spacer(minLength: 0)

            GlassIconButton(systemName: "bubble.left.and.bubble.right.fill", size: 42, action: onOpenMessages)
                .accessibilityLabel("Messages")
        }
        .padding(.horizontal, 4)
    }

    private var searchField: some View {
        HStack(spacing: 11) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color(hex: "BDD2EF"))

            TextField("Search Marketplace", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Theme.primaryText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Search Marketplace")

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
        .padding(.horizontal, 15)
        .frame(height: 48)
        .glassSurface(cornerRadius: 25, tint: Color(hex: "1B355B"), tintOpacity: 0.56)
    }

    private var categories: some View {
        HStack(spacing: 8) {
            ForEach(MarketplaceCategory.allCases) { category in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selectedCategory = category
                    }
                } label: {
                    VStack(spacing: 7) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "10213B", opacity: 0.92))
                                .frame(width: 58, height: 58)
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))

                            if selectedCategory == category {
                                Circle()
                                    .stroke(Theme.cyan, lineWidth: 2)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Theme.cyan.opacity(0.65), radius: 7)
                            }

                            Image(systemName: category.symbol)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(selectedCategory == category ? Theme.cyan : Color(hex: "B6C8E3"))
                        }
                        Text(category.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(selectedCategory == category ? Theme.primaryText : Color(hex: "BECBE0"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedCategory == category ? .isSelected : [])
            }
        }
        .padding(.vertical, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(Theme.cyan)
                .frame(width: 58, height: 58)
                .background(Circle().fill(Theme.cyan.opacity(0.1)))
            Text("No listings found")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.primaryText)
            Text("Try another search or category.")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassSurface(cornerRadius: Theme.Radius.card, tintOpacity: 0.43)
    }
}

private struct MarketplaceListingCard: View {
    let listing: MarketplaceListing
    let isSaved: Bool
    let onOpen: () -> Void
    let onToggleSaved: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 0) {
                    MarketplaceArtwork(style: listing.artwork)
                        .frame(height: 140)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(listing.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.84)

                        Text(listing.price)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.primaryText)

                        Label(listing.distance, systemImage: "mappin.and.ellipse")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "A6B7D1"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 11)
                    .padding(.top, 9)
                    .padding(.bottom, 11)
                    .padding(.trailing, 34)
                }
                .background(GlassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.65))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color(hex: "91B5E8", opacity: 0.14), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            Button(action: onToggleSaved) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSaved ? Theme.cyan : Color(hex: "D9E7F8"))
                    .frame(width: 38, height: 38)
                    .glassSurface(cornerRadius: 19, tint: Color(hex: "183052"), tintOpacity: 0.73)
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSaved ? "Remove \(listing.title) from saved" : "Save \(listing.title)")
            .padding(.trailing, 9)
            .padding(.bottom, 43)
        }
        .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 7)
    }
}

private struct MarketplaceListingDetail: View {
    @Environment(\.dismiss) private var dismiss

    let listing: MarketplaceListing
    let isSaved: Bool
    let onToggleSaved: () -> Void
    let onMessageSeller: () -> Void

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 17) {
                    ZStack(alignment: .topTrailing) {
                        MarketplaceArtwork(style: listing.artwork)
                            .frame(height: 285)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                        GlassIconButton(systemName: "xmark", size: 38) { dismiss() }
                            .accessibilityLabel("Close listing")
                            .padding(12)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(listing.title)
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primaryText)
                            Text(listing.price)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Theme.primaryText)
                        }

                        Spacer(minLength: 4)

                        Button(action: onToggleSaved) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(isSaved ? Theme.cyan : Theme.primaryText)
                                .frame(width: 44, height: 44)
                                .glassSurface(cornerRadius: 22, tintOpacity: 0.6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isSaved ? "Remove from saved" : "Save listing")
                    }

                    Label(listing.distance, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Description")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.primaryText)
                        Text(listing.description)
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.78))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .glassSurface(cornerRadius: 20, tintOpacity: 0.48)

                    HStack(spacing: 11) {
                        AvatarView(initials: listing.sellerInitials, palette: listing.sellerPalette, size: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(listing.sellerName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.primaryText)
                            Text("Seller")
                                .font(.caption)
                                .foregroundStyle(Theme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.tertiaryText)
                    }
                    .padding(14)
                    .glassSurface(cornerRadius: 20, tintOpacity: 0.46)

                    Color.clear.frame(height: 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onMessageSeller) {
                Label("Message seller", systemImage: "bubble.left.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.midnight)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Capsule().fill(Theme.accent))
                    .shadow(color: Theme.cyan.opacity(0.3), radius: 12, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial.opacity(0.65))
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MarketplaceView(store: MarketplaceStore())
}
