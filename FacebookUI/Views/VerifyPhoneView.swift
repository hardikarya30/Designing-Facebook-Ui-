//
//  VerifyPhoneView.swift
//  FacebookUI
//
//  Confirm the phone number with a six-digit code.
//

import SwiftUI

struct VerifyPhoneView: View {
    @ObservedObject var auth: AuthStore

    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var errorMessage: String?
    @State private var secondsRemaining = 24
    @FocusState private var isCodeFocused: Bool

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AppBackground()
            blueGlow

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    backRow

                    Image(systemName: "message.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.cyan)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Theme.cyan.opacity(0.14)))
                        .padding(.top, 10)

                    Text("Check your messages")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                        .padding(.top, 16)

                    Text("We sent a 6-digit code to \(auth.pendingPhone).")
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 6)
                        .fixedSize(horizontal: false, vertical: true)

                    codeBoxes
                        .padding(.top, 24)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(Theme.rose)
                            .padding(.top, 12)
                    }

                    resendRow
                        .padding(.top, 16)

                    verifyButton
                        .padding(.top, 22)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            isCodeFocused = true
        }
        .onReceive(timer) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            }
        }
    }

    private var blueGlow: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: "1D5AC4").opacity(0.55), Color(hex: "1D5AC4").opacity(0)],
                center: UnitPoint(x: 0.5, y: 0.08),
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [Theme.cyan.opacity(0.22), Theme.cyan.opacity(0)],
                center: UnitPoint(x: 0.15, y: 0.85),
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var backRow: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", size: 40) {
                auth.cancelVerification()
                dismiss()
            }
            .accessibilityLabel("Back")

            Spacer()
        }
    }

    // MARK: - Code

    private var codeBoxes: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isCodeFocused)
                .frame(width: 1, height: 1)
                .opacity(0.02)
                .onChange(of: code) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    code = String(digits.prefix(6))
                    errorMessage = nil
                }

            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    box(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isCodeFocused = true
            }
        }
    }

    private func box(at index: Int) -> some View {
        let characters = Array(code)
        let digit = index < characters.count ? String(characters[index]) : ""
        let isNext = index == characters.count && characters.count < 6

        return Text(digit)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundStyle(Theme.primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .glassSurface(cornerRadius: 14, shadowed: false)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isNext ? Theme.cyan.opacity(0.8) : Color.white.opacity(0.12),
                        lineWidth: isNext ? 1.5 : 1
                    )
            }
    }

    private var resendRow: some View {
        HStack(spacing: 5) {
            Text("Didn't get it?")
                .foregroundStyle(Theme.secondaryText)

            if secondsRemaining > 0 {
                Text("Resend in \(secondsRemaining)s")
                    .foregroundStyle(Theme.cyan)
            } else {
                Button("Resend code") {
                    secondsRemaining = 24
                    code = ""
                    errorMessage = nil
                    isCodeFocused = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(Theme.cyan)
            }
        }
        .font(.footnote)
        .frame(maxWidth: .infinity)
    }

    private var verifyButton: some View {
        Button(action: verify) {
            Text("Verify")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.midnight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Capsule(style: .continuous).fill(Theme.accent))
                .shadow(color: Theme.cyan.opacity(0.4), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }

    private func verify() {
        if auth.verify(code: code) {
            errorMessage = nil
        } else {
            errorMessage = "That code isn't right. Please try again."
        }
    }
}

#Preview {
    VerifyPhoneView(auth: AuthStore())
}
