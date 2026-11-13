//
//  YourPlanView.swift
//  FacebookUI
//
//  The current monthly plan, what it includes and when it renews.
//

import SwiftUI

struct YourPlanView: View {
    var onBack: () -> Void = {}
    var isActive: Bool = true
    var stores: EventStores? = nil

    @State private var isManageAlertPresented = false
    @State private var isPaymentsPresented = false
    @State private var isPauseAlertPresented = false
    @State private var isCancelAlertPresented = false
    @State private var isHistoryPresented = false
    @State private var isPaymentMethodPresented = false
    @State private var isVATFieldPresented = false
    @State private var isComparePresented = false
    @State private var isMembersPresented = false

    @StateObject private var history = PlanHistoryStore()
    @StateObject private var cards = PaymentCardsStore()
    @StateObject private var notes = PaymentNotesStore()
    @StateObject private var members = PlanMembersStore()

    @AppStorage("plan.paused") private var isPaused = false
    @AppStorage("plan.yearly") private var isYearly = false
    @AppStorage("plan.cancelled") private var isCancelled = false
    @AppStorage("plan.renewalReminder") private var renewalReminder = false
    @AppStorage("plan.chargeEmails") private var chargeEmails = false
    @AppStorage("plan.vatNumber") private var vatNumber = ""
    @AppStorage("auth.email") private var accountEmail = ""
    @AppStorage("auth.name") private var accountName = ""

    private let monthlyPrice: Double = 250
    private let fullMonthlyPrice: Double = 350

    private var price: Double {
        isYearly ? monthlyPrice * 10 : monthlyPrice
    }

    /// This year's charges so far, one for each month that has started.
    private var paymentCount: Int {
        Calendar.current.component(.month, from: Date())
    }

    private var savedTotal: Double {
        (fullMonthlyPrice - monthlyPrice) * Double(paymentCount)
    }

    private var savedText: String {
        "£" + savedTotal.formatted(.number.precision(.fractionLength(0)))
    }

    /// How much of the full price the discount covers, as a share of it.
    private var discountShare: Double {
        guard fullMonthlyPrice > 0 else { return 0 }
        return (fullMonthlyPrice - monthlyPrice) / fullMonthlyPrice
    }

    private var priceUnit: String {
        isYearly ? "/ year" : "/ month"
    }

    private var yearlyBinding: Binding<Bool> {
        Binding(
            get: { isYearly },
            set: { newValue in
                guard newValue != isYearly else { return }
                isYearly = newValue
                history.recordBillingChange(toYearly: newValue)
            }
        )
    }

    private var priceText: String {
        "£" + price.formatted(.number.precision(.fractionLength(0)))
    }

    private var headerSubtitle: String {
        let plan = isYearly ? "YEARLY" : "MONTHLY"
        if isCancelled { return plan + " · CANCELLED" }
        return plan + (isPaused ? " · PAUSED" : " · RENEWS SOON")
    }

    private var renewalBaseDate: Date {
        let calendar = Calendar.current
        let component: Calendar.Component = isYearly ? .year : .month
        return calendar.date(byAdding: component, value: 1, to: Date()) ?? Date()
    }

    private var pausedResumeDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: renewalBaseDate) ?? renewalBaseDate
    }

    private var renewalDate: Date {
        isPaused ? pausedResumeDate : renewalBaseDate
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    private var renewalText: String {
        formatted(renewalDate)
    }

    /// The renewal date without its year, for the lines that are short on room.
    private var renewalDayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: renewalDate)
    }

    private var nudgeDate: Date {
        Calendar.current.date(byAdding: .day, value: -2, to: renewalDate) ?? renewalDate
    }

    private var nudgeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: nudgeDate)
    }

    private var resumeText: String {
        formatted(pausedResumeDate)
    }

    private var daysLeft: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: renewalDate)
        ).day ?? 0
        return max(days, 0)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    if isActive && !isCancelled {
                        planCard
                        savingsCard
                        billingSwitch
                        compareRow
                        membersRow
                        renewalRow
                        manageButton
                        pauseButton
                        reminderRow
                        chargeEmailRow
                        paymentsRow
                        paymentMethodRow
                        vatRow
                        historyRow
                        cancelRow
                    } else {
                        emptyNote

                        if isCancelled {
                            restartButton
                        }
                    }

                    if !isCancelled {
                        Text("Cancel anytime before renewal.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "91A8C8"))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }

                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Manage plan", isPresented: $isManageAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Plan management isn't connected in this demo.")
        }
        .fullScreenCover(isPresented: $isPaymentsPresented) {
            PaymentsView(cards: cards, notes: notes, vatNumber: trimmedVAT, onBack: { isPaymentsPresented = false }, stores: stores)
        }
        .fullScreenCover(isPresented: $isPaymentMethodPresented) {
            PaymentMethodView(store: cards, onBack: { isPaymentMethodPresented = false })
        }
        .fullScreenCover(isPresented: $isHistoryPresented) {
            PlanHistoryView(store: history, onBack: { isHistoryPresented = false })
        }
        .fullScreenCover(isPresented: $isComparePresented) {
            ComparePlansView(isYearly: yearlyBinding, onBack: { isComparePresented = false })
        }
        .fullScreenCover(isPresented: $isMembersPresented) {
            PlanMembersView(
                store: members,
                price: price,
                isYearly: isYearly,
                renewalDate: renewalDate,
                accountName: accountName,
                onBack: { isMembersPresented = false }
            )
        }
    }

    private var shareMessage: String {
        "My plan: \(priceText) \(priceUnit) with 30% & 50% off every month, including all files. Next renewal \(renewalText)."
    }

    private var header: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 42, action: onBack)
                .accessibilityLabel("Back")

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text("Your plan")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .accessibilityAddTraits(.isHeader)

                Text(headerSubtitle)
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2.1)
                    .foregroundStyle(Color(hex: "91A8C8"))
                    .contentTransition(.opacity)
            }

            Spacer(minLength: 0)

            ShareLink(item: shareMessage) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText.opacity(0.9))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(GlassButtonStyle(cornerRadius: 21))
            .accessibilityLabel("Share your plan")
        }
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: isPaused ? "pause.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text(isPaused ? "PAUSED" : "ACTIVE")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(Theme.cyan.opacity(0.12)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(priceText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                        .contentTransition(.numericText())

                    Text(priceUnit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                        .contentTransition(.opacity)
                }
            }

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            HStack(spacing: 6) {
                Text("30% off")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))

                Text("50% off")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.violet)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Theme.violet.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(Theme.violet.opacity(0.3), lineWidth: 1))

                Spacer(minLength: 0)
            }

            Text("Including — For all files")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primaryText)

            if isPaused {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10, weight: .bold))

                    Text("Resumes \(renewalText)")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Theme.cyan)
                .transition(.opacity)
            }
        }
        .padding(16)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.72)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isYearly)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPaused)
    }

    private var savingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.violet)

                Text("You've saved")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))

                Spacer(minLength: 0)
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(savedText)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .contentTransition(.numericText())

                if paymentCount > 0 {
                    Text(paymentCount == 1 ? "/ 1 payment" : "/ \(paymentCount) payments")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "8FA3BF"))
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))

                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: proxy.size.width * discountShare)
                }
            }
            .frame(height: 6)
            .padding(.top, 2)

            Text(paymentCount == 0
                 ? "Your savings start with the first renewal."
                 : "With 30% & 50% off every month")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(paymentCount == 0 ? Color(hex: "8FA3BF") : Theme.cyan)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: paymentCount)
    }

    private var billingSwitch: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text("Monthly")
                    .font(.system(size: 13, weight: isYearly ? .medium : .semibold))
                    .foregroundStyle(isYearly ? Color(hex: "8FA3BF") : Theme.cyan)

                Spacer(minLength: 0)

                Toggle("", isOn: yearlyBinding)
                    .labelsHidden()
                    .tint(Theme.cyan)
                    .accessibilityLabel("Yearly billing")

                Spacer(minLength: 0)

                Text("Yearly")
                    .font(.system(size: 13, weight: isYearly ? .semibold : .medium))
                    .foregroundStyle(isYearly ? Theme.cyan : Color(hex: "8FA3BF"))
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .glassSurface(cornerRadius: 24, tint: Color(hex: "162E52"), tintOpacity: 0.55, shadowed: false)

            if isYearly {
                Text("Two months free — the same 30% & 50% discounts.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.cyan)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isYearly)
    }

    private var compareRow: some View {
        Button {
            isComparePresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "rectangle.split.2x1")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Compare plans")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("Monthly or yearly, side by side")
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
        .accessibilityLabel("Compare plans")
        .accessibilityHint("Shows monthly and yearly billing side by side")
    }

    private var membersRow: some View {
        Button {
            isMembersPresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "person.2")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.violet)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.violet.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan members")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text(membersSubtitle)
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
        .accessibilityLabel("Plan members")
        .accessibilityValue(membersSubtitle)
    }

    private var membersSubtitle: String {
        let count = members.peopleCount
        return count <= 1 ? "Just you" : "Split with \(count) people"
    }

    private var renewalRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text("Next renewal")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))

                Text(renewalText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)

                Text("\(daysLeft) days left")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
    }

    private var manageButton: some View {
        Button {
            isManageAlertPresented = true
        } label: {
            Text("Manage plan")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Capsule().fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.3), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.top, 2)
        .accessibilityLabel("Manage plan")
    }

    private var pauseButton: some View {
        Button {
            if isPaused {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isPaused = false
                }
                history.recordResume()
            } else {
                isPauseAlertPresented = true
            }
        } label: {
            HStack(spacing: 11) {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.14)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(isPaused ? "Resume plan" : "Pause for a month")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text(isPaused ? "Paused until \(renewalText)" : "Skip a month, keep your files")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 0)

                if isPaused {
                    Text("Resume")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.cyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.tertiaryText)
                }
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPaused ? "Resume plan" : "Pause for a month")
        .alert("Pause for a month?", isPresented: $isPauseAlertPresented) {
            Button("Pause plan") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isPaused = true
                }
                history.recordPause()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your plan pauses for one month. Nothing is charged, your files stay saved and renewal moves to \(resumeText).")
        }
    }

    private var reminderRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 11) {
                Image(systemName: "bell")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Reminder before renewal")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("A nudge two days before the renewal date")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 8)

                Toggle("", isOn: $renewalReminder)
                    .labelsHidden()
                    .tint(Theme.cyan)
                    .accessibilityLabel("Reminder before renewal")
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)

            if renewalReminder {
                Text("We'll nudge you on \(nudgeText)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.leading, 6)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: renewalReminder)
    }

    private var chargeEmailRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 11) {
                Image(systemName: "envelope")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Email me when a charge goes through")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("A receipt lands in your inbox each month")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "AFC2DF"))
                }

                Spacer(minLength: 8)

                Toggle("", isOn: $chargeEmails)
                    .labelsHidden()
                    .tint(Theme.cyan)
                    .accessibilityLabel("Email me when a charge goes through")
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)

            if chargeEmails {
                Text("Sent to \(chargeEmailAddress)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.leading, 6)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: chargeEmails)
    }

    private var chargeEmailAddress: String {
        accountEmail.isEmpty ? "hafreelancers@example.com" : accountEmail
    }

    private var paymentsRow: some View {
        Button {
            isPaymentsPresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.cyan.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Payments")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("This year's charges")
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
        .accessibilityLabel("Payments")
    }

    private var paymentMethodRow: some View {
        Button {
            isPaymentMethodPresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "creditcard")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.violet)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.violet.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Payment method")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text(cards.selectedCard?.label ?? "Choose a card")
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
        .accessibilityLabel("Payment method")
        .accessibilityValue(cards.selectedCard?.label ?? "No card chosen")
    }

    /// The VAT number with the stray spaces a typed number collects taken away.
    private var trimmedVAT: String {
        vatNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var vatRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isVATFieldPresented.toggle()
                }
            } label: {
                HStack(spacing: 11) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Theme.cyan.opacity(0.12)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("VAT number")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.primaryText)

                        Text(trimmedVAT.isEmpty ? "Add it to every receipt" : "Shown on your receipts")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "AFC2DF"))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isVATFieldPresented ? "chevron.up" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Theme.tertiaryText)
                }
                .padding(12)
                .contentShape(Rectangle())
                .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("VAT number")
            .accessibilityValue(trimmedVAT.isEmpty ? "Not set" : trimmedVAT)

            if !trimmedVAT.isEmpty {
                Text(trimmedVAT)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.cyan)
                    .padding(.leading, 6)
                    .transition(.opacity)
            }

            if isVATFieldPresented {
                HStack(spacing: 8) {
                    Image(systemName: "number")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.violet)

                    TextField("VAT registration number", text: $vatNumber)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.primaryText)
                        .tint(Theme.cyan)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .submitLabel(.done)

                    if !vatNumber.isEmpty {
                        Button {
                            vatNumber = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.tertiaryText)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear VAT number")
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 46)
                .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
                .accessibilityLabel("VAT registration number")
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: trimmedVAT.isEmpty)
    }

    private var historyRow: some View {
        Button {
            isHistoryPresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.violet)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.violet.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan history")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)

                    Text("This year's charges and changes")
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
        .accessibilityLabel("Plan history")
    }

    private var cancelRow: some View {
        Button {
            isCancelAlertPresented = true
        } label: {
            HStack(spacing: 11) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.rose)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.rose.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cancel plan")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(hex: "C9D6E8"))

                    Text("Runs until \(renewalText)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "8FA3BF"))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.tertiaryText)
            }
            .padding(12)
            .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.5, shadowed: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cancel plan")
        .alert("Cancel plan?", isPresented: $isCancelAlertPresented) {
            Button("Cancel plan", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isCancelled = true
                }
            }
            Button("Keep plan", role: .cancel) {}
        } message: {
            Text("Your plan runs until \(renewalText). Nothing more will be charged.")
        }
    }

    private var restartButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isCancelled = false
                isYearly = false
                isPaused = false
            }
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13, weight: .semibold))

                Text("Restart plan")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Theme.midnight)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Capsule().fill(Theme.accent))
            .shadow(color: Theme.cyan.opacity(0.3), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Restart plan")
    }

    private var emptyNote: some View {
        Text("No active plan — the monthly plan isn't running right now.")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color(hex: "AFC2DF"))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.58, shadowed: false)
    }
}

#Preview {
    YourPlanView()
}
