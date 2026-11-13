//
//  AuthStore.swift
//  FacebookUI
//
//  A local account: sign up, sign in, and staying signed in across launches.
//

import Combine
import CryptoKit
import Foundation

final class AuthStore: ObservableObject {

    @Published private(set) var isSignedIn: Bool
    @Published private(set) var staySignedIn: Bool
    @Published private(set) var name: String
    @Published private(set) var email: String
    @Published private(set) var phone: String
    @Published private(set) var pendingPhone: String = ""

    private var pendingName = ""
    private var pendingEmail = ""
    private var pendingHash = ""

    private let defaults: UserDefaults

    private enum Keys {
        static let signedIn = "auth.isSignedIn"
        static let staySignedIn = "auth.staySignedIn"
        static let name = "auth.name"
        static let email = "auth.email"
        static let phone = "auth.phone"
        static let passwordHash = "auth.passwordHash"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let staySignedIn = defaults.object(forKey: Keys.staySignedIn) as? Bool ?? true
        let storedEmail = defaults.string(forKey: Keys.email) ?? ""

        self.staySignedIn = staySignedIn
        self.name = defaults.string(forKey: Keys.name) ?? ""
        self.email = storedEmail
        self.phone = defaults.string(forKey: Keys.phone) ?? ""
        self.isSignedIn = Self.restoreSession(
            defaults: defaults,
            staySignedIn: staySignedIn,
            email: storedEmail
        )
    }

    /// Keeps the session from a previous launch, so the sign in screen is only
    /// shown once. Called from `init` every time the app starts.
    private static func restoreSession(defaults: UserDefaults, staySignedIn: Bool, email: String) -> Bool {
        guard staySignedIn, !email.isEmpty else { return false }
        return defaults.bool(forKey: Keys.signedIn)
    }

    /// Turns the "Stay signed in" preference on or off. Turning it off keeps
    /// the current session but forgets it for the next launch.
    func setStaySignedIn(_ isOn: Bool) {
        staySignedIn = isOn
        defaults.set(isOn, forKey: Keys.staySignedIn)
        defaults.set(isSignedIn && isOn, forKey: Keys.signedIn)
    }

    /// Creates the local account and waits for the phone code. Returns false when a field is missing.
    @discardableResult
    func signUp(fullName: String, email: String, password: String, phone: String) -> Bool {
        let name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let number = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty, !mail.isEmpty, !password.isEmpty, !number.isEmpty else {
            return false
        }

        pendingName = name
        pendingEmail = mail
        pendingPhone = number
        pendingHash = hash(password)
        return true
    }

    /// Confirms the phone number with the six-digit code, then signs in.
    @discardableResult
    func verify(code: String) -> Bool {
        guard !pendingPhone.isEmpty, code == "123456" else { return false }

        name = pendingName
        email = pendingEmail
        phone = pendingPhone
        defaults.set(pendingHash, forKey: Keys.passwordHash)
        persist()

        pendingPhone = ""
        isSignedIn = true
        defaults.set(staySignedIn, forKey: Keys.signedIn)
        return true
    }

    func cancelVerification() {
        pendingName = ""
        pendingEmail = ""
        pendingPhone = ""
        pendingHash = ""
    }

    /// Signs in with the stored account's email and password.
    /// Returns false when a field is missing or the details don't match.
    @discardableResult
    func signIn(email: String, password: String) -> Bool {
        let mail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !mail.isEmpty, !password.isEmpty else { return false }

        if let storedHash = defaults.string(forKey: Keys.passwordHash) {
            guard hash(password) == storedHash,
                  mail.caseInsensitiveCompare(self.email) == .orderedSame else {
                return false
            }
        } else {
            self.email = mail
        }

        persist()
        isSignedIn = true
        defaults.set(staySignedIn, forKey: Keys.signedIn)
        return true
    }

    @discardableResult
    func changePassword(currentPassword: String, newPassword: String) -> Bool {
        guard !currentPassword.isEmpty,
              !newPassword.isEmpty,
              let storedHash = defaults.string(forKey: Keys.passwordHash),
              hash(currentPassword) == storedHash else {
            return false
        }

        defaults.set(hash(newPassword), forKey: Keys.passwordHash)
        return true
    }

    func signOut() {
        isSignedIn = false
        defaults.set(false, forKey: Keys.signedIn)
    }

    private func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func persist() {
        defaults.set(name, forKey: Keys.name)
        defaults.set(email, forKey: Keys.email)
        defaults.set(phone, forKey: Keys.phone)
    }
}
