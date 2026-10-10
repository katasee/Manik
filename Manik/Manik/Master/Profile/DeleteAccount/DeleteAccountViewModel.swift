import Foundation
import Observation

@MainActor
@Observable
final class DeleteAccountViewModel {
    var password = ""

    private(set) var isDeleting = false
    private(set) var failure: PasswordFailure?

    private let authRepository: AuthRepository
    private let userDataRepository: UserDataRepository

    init(
        authRepository: AuthRepository = FirebaseAuthRepository(),
        userDataRepository: UserDataRepository = FirestoreUserDataRepository()
    ) {
        self.authRepository = authRepository
        self.userDataRepository = userDataRepository
    }

    var canSubmit: Bool {
        password.isEmpty == false
    }

    func delete() async -> Bool {
        guard isDeleting == false, canSubmit else { return false }

        isDeleting = true
        failure = nil
        defer { isDeleting = false }

        do {
            try await authRepository.reauthenticate(password: password)
            try await userDataRepository.deleteAllData()
            try await authRepository.deleteAccount()

            return true
        } catch let error as AccountError {
            failure = PasswordFailure(error)

            return false
        } catch {
            failure = .generic

            return false
        }
    }
}
