//
//  PlanReceiptView.swift
//  FacebookUI
//
//  A single charge's receipt: what was paid, when, and how.
//

import SwiftUI
import UIKit

struct PlanReceiptView: View {
    let dateText: String
    let amount: Double
    let billingPeriod: String
    let invoiceNumber: String
    let paidWith: String
    let vatNumber: String
    @ObservedObject var notes: PaymentNotesStore

    var stores: EventStores? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var noteDraft = ""

    @StateObject private var localMessages = MessagesStore()
    @StateObject private var localFeed = FeedStore()
    @StateObject private var localComments = CommentsStore()
    @StateObject private var localSaved = SavedPostsStore()

    @State private var openedConversation: Conversation?
    @State private var isHelpPresented = false
    @State private var pdfURL: URL?

    private var messagesStore: MessagesStore {
        stores?.messages ?? localMessages
    }

    private var feedStore: FeedStore {
        stores?.feed ?? localFeed
    }

    private var commentsStore: CommentsStore {
        stores?.comments ?? localComments
    }

    private var savedStore: SavedPostsStore {
        stores?.saved ?? localSaved
    }

    private var amountText: String {
        "£" + amount.formatted(.number.precision(.fractionLength(0)))
    }

    private var planName: String {
        billingPeriod == "Yearly" ? "Yearly plan" : "Monthly plan"
    }

    private var shareMessage: String {
        "Receipt — \(amountText) for my \(planName.lowercased()), \(dateText) · Invoice \(invoiceNumber) · Paid with \(paidWith)."
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        summaryCard
                        detailCard
                        paidWithRow

                        Text("Invoices are sent to your email.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "91A8C8"))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)

                        noteField
                        shareButton
                        helpButton
                        pdfButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .onAppear {
            noteDraft = notes.note(for: invoiceNumber)
            writeReceiptPDF()
        }
        .onChange(of: noteDraft) { _, newValue in
            notes.setNote(newValue, for: invoiceNumber)
            writeReceiptPDF()
        }
        .fullScreenCover(isPresented: $isHelpPresented) {
            if let openedConversation {
                ConversationView(
                    conversation: openedConversation,
                    store: messagesStore,
                    feedStore: feedStore,
                    commentsStore: commentsStore,
                    savedStore: savedStore
                )
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.violet)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.violet.opacity(0.15)))

            Text("Receipt")
                .font(.headline)
                .foregroundStyle(Theme.primaryText)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 8)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                    .overlay {
                        Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private var summaryCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.primaryText)
                .frame(width: 44, height: 44)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.violet.opacity(0.16))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Theme.violet.opacity(0.35), lineWidth: 1)
                }
                .padding(.bottom, 2)

            Text(amountText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)

            Text(dateText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))

            Text("Paid")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Theme.cyan)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Capsule().fill(Theme.cyan.opacity(0.14)))
                .overlay(Capsule().strokeBorder(Theme.cyan.opacity(0.3), lineWidth: 1))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .glassSurface(cornerRadius: 22, tint: Color(hex: "142846"), tintOpacity: 0.72)
    }

    private var detailCard: some View {
        VStack(spacing: 10) {
            detailRow("Plan", planName)

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            detailRow("Billing period", billingPeriod)

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            detailRow("Status", "Paid", valueColor: Theme.cyan)

            Rectangle()
                .fill(Theme.hairline)
                .frame(height: 1)

            detailRow("Invoice", invoiceNumber)

            if !vatNumber.isEmpty {
                Rectangle()
                    .fill(Theme.hairline)
                    .frame(height: 1)

                detailRow("VAT number", vatNumber)
            }
        }
        .padding(14)
        .glassSurface(cornerRadius: 20, tint: Color(hex: "142846"), tintOpacity: 0.66, shadowed: false)
    }

    private func detailRow(_ label: String, _ value: String, valueColor: Color = Theme.primaryText) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(hex: "AFC2DF"))

            Spacer(minLength: 0)

            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }

    private var noteField: some View {
        HStack(spacing: 8) {
            Image(systemName: "pencil")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.violet)

            TextField("Add a note — what was this for?", text: $noteDraft, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .tint(Theme.cyan)
                .lineLimit(1...4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .glassSurface(cornerRadius: 14, tint: Color(hex: "10213C"), tintOpacity: 0.5, shadowed: false)
        .accessibilityLabel("Add a note — what was this for?")
    }

    private var paidWithRow: some View {
        HStack(spacing: 11) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.cyan)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Theme.cyan.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text("Paid with")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: "AFC2DF"))

                Text(paidWith)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .glassSurface(cornerRadius: 18, tint: Color(hex: "142846"), tintOpacity: 0.62, shadowed: false)
    }

    private var shareButton: some View {
        ShareLink(item: shareMessage) {
            HStack(spacing: 7) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 13, weight: .semibold))

                Text("Share receipt")
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
        .accessibilityLabel("Share receipt")
    }

    private var helpButton: some View {
        Button(action: openHelp) {
            HStack(spacing: 7) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 13, weight: .semibold))

                Text("Get help with this charge")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Color(hex: "D7E3F5"))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Get help with this charge")
    }

    @ViewBuilder
    private var pdfButton: some View {
        if let pdfURL {
            ShareLink(item: pdfURL) {
                HStack(spacing: 7) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 13, weight: .semibold))

                    Text("Save as PDF")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "D7E3F5"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Capsule().fill(Color(hex: "10213A", opacity: 0.96)))
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save as PDF")
        }
    }

    /// Draws the receipt onto a single white A4 page and saves it as <invoice number>.pdf.
    private func writeReceiptPDF() {
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margin: CGFloat = 56

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(invoiceNumber).pdf")

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "Receipt \(invoiceNumber)",
            kCGPDFContextCreator as String: "FacebookUI"
        ]

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight),
            format: format
        )

        let navy = UIColor(red: 0.07, green: 0.11, blue: 0.20, alpha: 1)
        let grey = UIColor(white: 0.45, alpha: 1)
        let violet = UIColor(red: 0.42, green: 0.31, blue: 0.60, alpha: 1)

        var rows: [(String, String)] = [
            ("Plan", planName),
            ("Billing period", billingPeriod),
            ("Status", "Paid"),
            ("Invoice", invoiceNumber),
            ("Paid with", paidWith)
        ]

        if !vatNumber.isEmpty {
            rows.append(("VAT number", vatNumber))
        }

        do {
            try renderer.writePDF(to: url) { context in
            context.beginPage()

            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

            violet.setFill()
            context.fill(CGRect(x: 0, y: 0, width: pageWidth, height: 6))

            var y: CGFloat = 72

            drawText("Receipt", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 28, weight: .bold), color: navy)
            y += 40

            drawText("Invoice \(invoiceNumber)", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 12, weight: .medium), color: grey)
            y += 34

            drawText(amountText, at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 40, weight: .bold), color: navy)
            y += 52

            drawText("\(dateText) · \(planName)", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 13, weight: .medium), color: grey)
            y += 34

            UIColor(white: 0.85, alpha: 1).setFill()
            context.fill(CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 1))
            y += 30

            for (label, value) in rows {
                drawText(label, at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 12, weight: .regular), color: grey)

                let valueFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
                let valueWidth = textSize(value, font: valueFont).width
                drawText(
                    value,
                    at: CGPoint(x: pageWidth - margin - valueWidth, y: y),
                    font: valueFont,
                    color: navy
                )

                y += 28
            }

            let note = noteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
            if !note.isEmpty {
                y += 16
                drawText("Note", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 11, weight: .medium), color: grey)
                y += 22

                let noteAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: navy
                ]
                let noteWidth = pageWidth - margin * 2
                let noteHeight = (note as NSString).boundingRect(
                    with: CGSize(width: noteWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: noteAttributes,
                    context: nil
                ).height
                (note as NSString).draw(
                    with: CGRect(x: margin, y: y, width: noteWidth, height: noteHeight),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: noteAttributes,
                    context: nil
                )
            }

            drawText(
                "Invoices are sent to your email.",
                at: CGPoint(x: margin, y: pageHeight - 72),
                font: .systemFont(ofSize: 10, weight: .regular),
                color: grey
            )
        }
        } catch {
            pdfURL = nil
            return
        }

        if FileManager.default.fileExists(atPath: url.path) {
            pdfURL = url
        }
    }

    private func drawText(_ text: String, at point: CGPoint, font: UIFont, color: UIColor) {
        (text as NSString).draw(
            at: point,
            withAttributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
    }

    private func textSize(_ text: String, font: UIFont) -> CGSize {
        (text as NSString).size(withAttributes: [.font: font])
    }

    private func openHelp() {
        let conversation = messagesStore.startPlanSupportConversation(
            dateText: dateText,
            amountText: amountText,
            invoiceNumber: invoiceNumber
        )

        openedConversation = conversation
        isHelpPresented = true
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            PlanReceiptView(
                dateText: "1 June 2025",
                amount: 250,
                billingPeriod: "Monthly",
                invoiceNumber: "FB-2025-06",
                paidWith: "Visa ending 4242",
                vatNumber: "GB 123 4567 89",
                notes: PaymentNotesStore()
            )
        }
}
