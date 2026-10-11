import Foundation
import Observation

@MainActor
@Observable
final class ClientListViewModel {
    var query = ""

    private(set) var hasLoaded = false
    private(set) var hasFailed = false
    private var clients: [Client] = []

    private let clientRepository: ClientRepository

    init(clientRepository: ClientRepository = FirestoreClientRepository()) {
        self.clientRepository = clientRepository
    }

    var items: [ClientItem] {
        clients
            .filter { $0.matches(query) }
            .map(ClientItem.init)
    }

    var totalCount: Int {
        clients.count
    }

    func observeClients() async {
        hasFailed = false

        do {
            for try await updatedClients in clientRepository.observeClients() {
                clients = updatedClients.sortedNewestFirst()
                hasLoaded = true
            }
        } catch {
            hasFailed = true
            hasLoaded = true
        }
    }

    func makeAddFormViewModel() -> ClientFormViewModel {
        ClientFormViewModel(takenHandles: takenHandles, clientRepository: clientRepository)
    }

    private var takenHandles: Set<String> {
        Set(clients.compactMap { $0.instagram.map(Client.normalizedInstagram) })
    }
}
