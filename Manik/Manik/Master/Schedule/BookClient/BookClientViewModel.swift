import Foundation
import Observation

@MainActor
@Observable
final class BookClientViewModel: Identifiable {
    let id = UUID()

    private var picker = ClientPicker()
    private var clients: [Client]
    private var selectedServiceId: String?

    private let slot: Slot
    private let offeredServices: [Service]
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
        offeredServices = services
            .filter(\.isOffered)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        self.slotRepository = slotRepository
        self.clientRepository = clientRepository
    }

    var searchText: String {
        get { picker.searchText }
        set { picker.searchText = newValue }
    }

    var subtitle: String {
        let day = DateFormat.date
            .date(from: slot.date)
            .map(DateFormat.weekdayDayMonth.string(from:)) ?? slot.date

        return "\(day) · \(DateFormat.displayTime(slot.time))"
    }

    var options: [BookClientOption] {
        picker.options(from: clients)
    }

    var services: [BookServiceChip] {
        offeredServices.compactMap { service in
            service.id.map { id in
                BookServiceChip(
                    id: id,
                    title: "\(service.name) · \(ServiceFormat.price(service.price))",
                    isSelected: id == selectedServiceId
                )
            }
        }
    }

    var canBook: Bool {
        picker.selectedId != nil
    }

    func toggleClient(_ id: String) {
        picker.toggle(id)
    }

    func toggleService(_ id: String) {
        selectedServiceId = selectedServiceId == id ? nil : id
    }

    func makeNewClientForm() -> ClientFormViewModel {
        ClientFormViewModel(takenHandles: takenHandles, clientRepository: clientRepository)
    }

    func select(newClient: Client) {
        guard let id = newClient.id else { return }

        clients.append(newClient)
        picker.select(id)
    }

    func book() {
        guard let slotId = slot.id, let clientId = picker.selectedId else { return }

        let service = offeredServices.first { $0.id == selectedServiceId }

        try? slotRepository.book(slotId: slotId, SlotBooking(clientId: clientId, service: service))
    }

    private var takenHandles: Set<String> {
        Set(clients.compactMap { $0.instagram.map(Client.normalizedInstagram) })
    }
}
