import Foundation
import Observation

enum BookingActionsMode {
    case actions
    case changeService
}

@MainActor
@Observable
final class BookingActionsViewModel: Identifiable {
    let id = UUID()

    private(set) var mode = BookingActionsMode.actions
    private var serviceChoice: ServiceChoice

    private let slot: Slot
    private let client: Client?
    private let initialChoice: ServiceChoice
    private let slotRepository: SlotRepository

    init(
        slot: Slot,
        client: Client?,
        services: [Service],
        slotRepository: SlotRepository
    ) {
        self.slot = slot
        self.client = client
        self.slotRepository = slotRepository
        initialChoice = ServiceChoice(services: services, pinning: slot)
        serviceChoice = initialChoice
    }

    var title: String {
        client?.displayName ?? String(localized: "schedule.slot.clientDeleted")
    }

    var subtitle: String {
        let service = slot.serviceName ?? String(localized: "service.none")

        return "\(SlotWhen.text(for: slot)) · \(service)"
    }

    var contacts: [ClientContact] {
        client?.contacts ?? []
    }

    var cardClientId: String? {
        client?.id
    }

    var canChangeService: Bool {
        serviceChoice.chips.isEmpty == false
    }

    var services: [BookServiceChip] {
        serviceChoice.chips
    }

    var hasServiceChanged: Bool {
        serviceChoice.selectedId != slot.serviceId
    }

    func startChangingService() {
        mode = .changeService
    }

    func stopChangingService() {
        serviceChoice = initialChoice
        mode = .actions
    }

    func toggleService(_ id: String) {
        serviceChoice.toggle(id)
    }

    func saveService() {
        guard hasServiceChanged, let slotId = slot.id, let clientId = slot.clientId else { return }

        let booking = SlotBooking(clientId: clientId, service: serviceChoice.selectedService)

        try? slotRepository.book(slotId: slotId, booking)
    }

    func cancelBooking() {
        guard let slotId = slot.id else { return }

        try? slotRepository.clearBooking(slotId: slotId)
    }
}
