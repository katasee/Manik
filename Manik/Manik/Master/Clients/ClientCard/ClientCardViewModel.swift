import Foundation
import Observation

@MainActor
@Observable
final class ClientCardViewModel {
    private(set) var isDeleted = false
    private var client: Client?

    private let clientId: String
    private let takenHandles: Set<String>
    private let clientRepository: ClientRepository

    init(
        clientId: String,
        takenHandles: Set<String>,
        clientRepository: ClientRepository
    ) {
        self.clientId = clientId
        self.takenHandles = takenHandles
        self.clientRepository = clientRepository
    }

    var card: ClientCard? {
        if let client {
            ClientCard(client: client)
        } else {
            nil
        }
    }

    func observeClient() async {
        do {
            for try await updatedClient in clientRepository.observeClient(id: clientId) {
                if let updatedClient {
                    client = updatedClient
                } else if client != nil {
                    isDeleted = true
                }
            }
        } catch {
            return
        }
    }

    func makeEditFormViewModel() -> ClientFormViewModel? {
        guard let client else { return nil }

        return ClientFormViewModel(
            editing: client,
            takenHandles: takenHandles,
            clientRepository: clientRepository
        )
    }
}
