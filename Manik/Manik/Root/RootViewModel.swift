import Foundation
import Observation

@MainActor
@Observable
final class RootViewModel {
    enum State {
        case loading
        case signedOut
        case signedIn(UserProfile)
    }

    var state: State = .loading
    var errorMessage: String?

    private let repository: AuthRepository

    init(repository: AuthRepository = FirebaseAuthRepository()) {
        self.repository = repository
    }

    func refresh() async {
        guard repository.currentUserId != nil else {
            state = .signedOut
            return
        }

        do {
            let profile = try await repository.fetchProfile()
            errorMessage = nil
            state = .signedIn(profile)
        } catch AccountError.profileNotFound {
            reset()
        } catch {
            errorMessage = error.localizedDescription
            state = .signedOut
        }
    }

    func reset() {
        try? repository.signOut()
        errorMessage = nil
        state = .signedOut
    }

    func signOut() {
        do {
            try repository.signOut()
            errorMessage = nil
            state = .signedOut
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
