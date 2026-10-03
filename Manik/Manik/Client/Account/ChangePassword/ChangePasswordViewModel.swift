import Foundation
import Observation

@MainActor
@Observable
final class ChangePasswordViewModel {
    static let minimumLength = 6

    var currentPassword = ""
    var newPassword = ""
    var repeatedPassword = ""

    private(set) var isSaving = false
    private(set) var isChanged = false
    private(set) var failure: PasswordFailure?

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    var canSubmit: Bool {
        currentPassword.isEmpty == false
            && newPassword.isEmpty == false
            && repeatedPassword.isEmpty == false
    }

    func submit() async {
        guard isSaving == false, canSubmit else { return }

        guard newPassword == repeatedPassword else {
            failure = .mismatch

            return
        }

        guard newPassword.count >= Self.minimumLength else {
            failure = .weak

            return
        }

        isSaving = true
        failure = nil
        defer { isSaving = false }

        do {
            try await authRepository.reauthenticate(password: currentPassword)
            try await authRepository.updatePassword(to: newPassword)
            isChanged = true
        } catch let error as AccountError {
            failure = PasswordFailure(error)
        } catch {
            failure = .generic
        }
    }
}
