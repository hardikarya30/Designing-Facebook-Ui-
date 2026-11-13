//
//  DiscountView.swift
//  FacebookUI
//
//  This month's discounts and the monthly price card, plus the web page version.
//

import SwiftUI
import WebKit

struct DiscountView: View {
    var onBack: () -> Void = {}
    var stores: EventStores? = nil

    @State private var isWebPagePresented = false
    @State private var isPlanPresented = false
    @State private var isYearlyBilling = false
    @State private var promoDraft = ""
    @State private var appliedPromo: String?
    @State private var promoError: String?

    private let basePrice: Double = 250

    private var yearlyBasePrice: Double { basePrice * 10 }

    private var billingBasePrice: Double {
        isYearlyBilling ? yearlyBasePrice : basePrice
    }

    private var priceUnit: String {
        isYearlyBilling ? "/ year" : "/ month"
    }

    private var promoPercent: Int? {
        switch appliedPromo {
        case "SAVE30": return 30
        case "SAVE50": return 50
        default: return nil
        }
    }

    private var currentPrice: Double {
        guard let promoPercent else { return billingBasePrice }
        return billingBasePrice * (1 - Double(promoPercent) / 100)
    }

    private var priceText: String {
        String(format: "£%.0f", currentPrice)
    }

    private var canApplyPromo: Bool {
        !promoDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    hero
                    billingSwitch
                    priceCard
                    promoForm
                    discountBreakdown
                    webPageButton
                    planRow

                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isWebPagePresented) {
            DiscountWebView()
        }
        .fullScreenCover(isPresented: $isPlanPresented) {
            YourPlanView(onBack: { isPlanPresented = false }, stores: stores)
        }
    }

    private var shareMessage: String {
        "30% & 50% off every month — £250 / month, including all files."
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("Discounts")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text("30% & 50% OFF EVERY MONTH")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
            }

            Spacer(minLength: 0)

            ShareLink(item: shareMessage) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(GlassButtonStyle(cornerRadius: 21))
            .accessibilityLabel("Share the discount")
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "162B54"), Color(hex: "3B2A6B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 190, height: 190)
                .offset(x: 175, y: -45)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text("SAVE EVERY MONTH")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.9)
                }
                .foregroundStyle(Theme.cyan)

                Text("30% & 50% off")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)

                Text("Two discounts on every month of your plan.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "B8C8E0"))
            }
            .padding(20)
        }
        .frame(height: 176)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var billingSwitch: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text("Monthly")
                    .font(.system(size: 13, weight: isYearlyBilling ? .medium : .semibold))
                    .foregroundStyle(isYearlyBilling ? Color(hex: "8FA3BF") : Theme.cyan)

                Spacer(minLength: 0)

                Toggle("", isOn: $isYearlyBilling)
                    .labelsHidden()
                    .tint(Theme.cyan)
                    .accessibilityLabel("Yearly billing")

                Spacer(minLength: 0)

                Text("Yearly")
                    .font(.system(size: 13, weight: isYearlyBilling ? .semibold : .medium))
                    .foregroundStyle(isYearlyBilling ? Theme.cyan : Color(hex: "8FA3BF"))
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .glassSurface(cornerRadius: 24, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)

            if isYearlyBilling {
                Text("Two months free — the same 30% & 50% discounts.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: isYearlyBilling)
    }

    private var priceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(priceText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .contentTransition(.numericText())

                if appliedPromo != nil {
                    Text(String(format: "£%.0f", billingBasePrice))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(hex: "8FA3BF"))
                        .strikethrough()
                }

                Text(priceUnit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))

                Spacer(minLength: 0)

                Text("30% off")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
            }

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            HStack(spacing: 10) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Including")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))

                    Text("For all files")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                }

                Spacer(minLength: 0)

                Text("50% off")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.violet)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.violet.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.violet.opacity(0.3), lineWidth: 1))
            }

            if let appliedPromo, let promoPercent {
                Rectangle()
                    .fill(Theme.hairline)
                    .frame(height: 1)

                HStack(spacing: 10) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.cyan)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Promo \(appliedPromo)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "AFC2DF"))

                        Text("\(promoPercent)% off")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.primaryText)
                    }

                    Spacer(minLength: 0)

                    Button {
                        removePromo()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove promo code \(appliedPromo)")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.7)
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: appliedPromo)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isYearlyBilling)
    }

    private var promoForm: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField("Promo code", text: $promoDraft)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .tint(Theme.cyan)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit(applyPromo)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .glassSurface(cornerRadius: 23, tint: Color(hex: "1B355B"), tintOpacity: 0.56, shadowed: false)
                    .accessibilityLabel("Promo code")

                Button(action: applyPromo) {
                    Text("Apply")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.midnight)
                        .padding(.horizontal, 18)
                        .frame(height: 46)
                        .background(Capsule().fill(Theme.accent))
                        .opacity(canApplyPromo ? 1 : 0.5)
                }
                .buttonStyle(.plain)
                .disabled(!canApplyPromo)
                .accessibilityLabel("Apply promo code")
            }

            if let promoError {
                Text(promoError)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "FF5C8A"))
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: promoError)
    }

    private func applyPromo() {
        let code = promoDraft.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty else {
            promoError = "Enter a promo code."
            return
        }

        guard code == "SAVE30" || code == "SAVE50" else {
            withAnimation(.easeOut(duration: 0.2)) {
                promoError = "That code isn't valid."
            }
            return
        }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            appliedPromo = code
            promoDraft = ""
            promoError = nil
        }
    }

    private func removePromo() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            appliedPromo = nil
            promoError = nil
        }
    }

    private var discountBreakdown: some View {
        HStack(spacing: 10) {
            discountTile(percent: "30%", caption: "Off every month", tint: Theme.cyan)
            discountTile(percent: "50%", caption: "Off every month", tint: Theme.violet)
        }
    }

    private func discountTile(percent: String, caption: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(percent)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(tint)

            Text(caption)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62)
    }

    private var planRow: some View {
        Button {
            isPlanPresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your plan")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("\(String(format: "£%.0f", billingBasePrice)) \(priceUnit) · including all files")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
        }
        .buttonStyle(.plain)
        .padding(.top, 2)
        .accessibilityLabel("Your plan")
    }

    private var webPageButton: some View {
        Button {
            isWebPagePresented = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("View the webpage")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Theme.midnight)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Capsule().fill(Theme.accent))
            .shadow(color: Theme.cyan.opacity(0.3), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.top, 2)
        .accessibilityLabel("View the discounts webpage")
    }
}

// MARK: - Web page

private struct DiscountWebView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Discounts")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)

                    Spacer(minLength: 0)

                    GlassIconButton(systemName: "xmark", size: 36) {
                        dismiss()
                    }
                    .accessibilityLabel("Close webpage")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

                DiscountWebContent()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct DiscountWebContent: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        if let url = Bundle.main.url(forResource: "discounts", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

#Preview {
    DiscountView()
}
