import Foundation
import Observation

@MainActor
@Observable
final class ProfileFormViewModel {
    var name: String
    var phone: String
    var instagram: String
    var telegram: String

    private(set) var hasSubmitted = false
    private(set) var hasFailed = false
    private(set) var isSaving = false

    private let profile: UserProfile
    private let userRepository: UserRepository

    init(profile: UserProfile, userRepository: UserRepository) {
        self.profile = profile
        self.userRepository = userRepository
        name = profile.name
        phone = PhoneFormat.grouped(PhoneFormat.national(from: profile.phone ?? ""))
        instagram = profile.instagram ?? ""
        telegram = profile.telegram ?? ""
    }

    var canSubmit: Bool {
        trimmed(name).isEmpty == false
    }

    var showsPhoneError: Bool {
        hasSubmitted && isPhoneValid == false
    }

    private var phoneDigits: String {
        PhoneFormat.national(from: phone)
    }

    private var isPhoneValid: Bool {
        phoneDigits.isEmpty || PhoneFormat.isComplete(phoneDigits)
    }

    func normalizePhone() {
        phone = PhoneFormat.grouped(phoneDigits)
    }

    func submit() async -> UserProfile? {
        guard isSaving == false, canSubmit else { return nil }

        hasSubmitted = true

        guard isPhoneValid else { return nil }

        isSaving = true
        hasFailed = false
        defer { isSaving = false }

        let edit = ProfileEdit(
            name: trimmed(name),
            phone: PhoneFormat.stored(national: phoneDigits),
            instagram: handle(instagram),
            telegram: handle(telegram)
        )

        do {
            try await userRepository.updateProfile(uid: profile.uid, edit: edit)
            return updated(with: edit)
        } catch {
            hasFailed = true
            return nil
        }
    }

    private func updated(with edit: ProfileEdit) -> UserProfile {
        var updated = profile
        updated.name = edit.name
        updated.phone = edit.phone
        updated.instagram = edit.instagram
        updated.telegram = edit.telegram

        return updated
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func optional(_ text: String) -> String? {
        let value = trimmed(text)

        return value.isEmpty ? nil : value
    }

    private func handle(_ text: String) -> String? {
        guard let value = optional(text) else { return nil }

        return optional(String(value.drop(while: { $0 == "@" })))
    }
}
