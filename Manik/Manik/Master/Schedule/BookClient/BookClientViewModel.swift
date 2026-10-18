import Foundation
import Observation

@MainActor
@Observable
final class BookClientViewModel: Identifiable {
    let id = UUID()

    private var picker = ClientPicker()
    private var clients: [Client]
    private var serviceChoice: ServiceChoice

    private let slot: Slot
    private let slotRepository: SlotRepository
    private let clientRepository: ClientRepository

    init(
        slot: Slot,
        clients: [Client],
        services: [Service],
        slotRepository: SlotRepository,
        clientRepository: ClientRepository
    ) {
        self.slot = slot
        self.clients = clients
        serviceChoice = ServiceChoice(services: services)
        self.slotRepository = slotRepository
        self.clientRepository = clientRepository
    }

    var searchText: String {
        get { picker.searchText }
        set { picker.searchText = newValue }
    }

    var subtitle: String {
        SlotWhen.text(for: slot)
    }

    var options: [BookClientOption] {
        picker.options(from: clients)
    }

    var services: [BookServiceChip] {
        serviceChoice.chips
    }

    var canBook: Bool {
        picker.selectedId != nil
    }

    func toggleClient(_ id: String) {
        picker.toggle(id)
    }

    func toggleService(_ id: String) {
        serviceChoice.toggle(id)
    }

    func makeNewClientForm() -> ClientFormViewModel {
        ClientFormViewModel(takenHandles: clients.takenHandles, clientRepository: clientRepository)
    }

    func select(newClient: Client) {
        guard let id = newClient.id else { return }

        clients.append(newClient)
        picker.select(id)
    }

    func book() {
        guard let slotId = slot.id, let clientId = picker.selectedId else { return }

        let booking = SlotBooking(clientId: clientId, service: serviceChoice.selectedService)

        try? slotRepository.book(slotId: slotId, booking)
    }
}
