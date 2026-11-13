//
//  Theme.swift
//  FacebookUI
//
//  The app's visual language: a midnight navy canvas, deep blue glass,
//  electric cyan and violet accents.
//

import Foundation
import SwiftUI

extension Color {
    /// Creates a color from a hexadecimal string such as "00CFFF".
    init(hex: String, opacity: Double = 1) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum Theme {

    // MARK: - Canvas

    static let midnight = Color(hex: "080D1B")
    static let midnightDeep = Color(hex: "05080F")
    static let deepBlue = Color(hex: "162B54")
    static let ink = Color(hex: "10182F")

    // MARK: - Accents

    static let cyan = Color(hex: "00CFFF")
    static let violet = Color(hex: "A78BFA")
    static let rose = Color(hex: "FF5C8A")

    // MARK: - Type

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.58)
    static let tertiaryText = Color.white.opacity(0.38)
    static let hairline = Color.white.opacity(0.1)

    // MARK: - Gradients

    static let accent = LinearGradient(
        colors: [cyan, violet],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let accentDiagonal = LinearGradient(
        colors: [cyan, violet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Geometry

    enum Radius {
        static let card: CGFloat = 26
        static let tile: CGFloat = 20
        static let field: CGFloat = 20
        static let bar: CGFloat = 28
    }
}
