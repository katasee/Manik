import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    var selectedDate = Date.now

    private(set) var hasLoaded = false
    private(set) var hasFailed = false
    private var slots: [Slot] = []
    private var directory = ClientDirectory(clients: [], isLoaded: false)
    private var services: [Service] = []

    private let slotRepository: SlotRepository
    private let clientRepository: ClientRepository
    private let serviceRepository: ServiceRepository

    var monthTitle: String {
        DateFormat.monthYear.string(from: selectedDate).capitalized
    }

    var areSlotsReady: Bool {
        hasLoaded && hasFailed == false
    }

    init(
        slotRepository: SlotRepository = FirestoreSlotRepository(),
        clientRepository: ClientRepository = FirestoreClientRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository()
    ) {
        self.slotRepository = slotRepository
        self.clientRepository = clientRepository
        self.serviceRepository = serviceRepository
    }

    func items(now: Date) -> [SlotItem] {
        let day = DateFormat.date.string(from: selectedDate)

        return slots
            .filter { $0.date == day }
            .sorted(by: Slot.chronologically)
            .map { slot in
                SlotItem(
                    slot: slot,
                    clientName: slot.clientId.map(directory.name(for:)) ?? "",
                    now: now
                )
            }
    }

    func observeSlots() async {
        hasFailed = false

        do {
            for try await updatedSlots in slotRepository.observeSlots() {
                slots = updatedSlots
                hasLoaded = true
            }
        } catch {
            slots = []
            hasFailed = true
            hasLoaded = true
        }
    }

    func observeClients() async {
        do {
            for try await clients in clientRepository.observeClients() {
                directory = ClientDirectory(clients: clients, isLoaded: true)
            }
        } catch {
            directory = ClientDirectory(clients: [], isLoaded: false)
        }
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices
        }
    }

    func select(dayId: String) {
        guard let date = DateFormat.date.date(from: dayId) else { return }

        selectedDate = date
    }

    func delete(id: String) {
        try? slotRepository.delete(id: id)
    }

    func makeFillMonthViewModel(now: Date = .now) -> FillMonthViewModel {
        FillMonthViewModel(
            month: selectedDate,
            existing: slots,
            now: now,
            slotRepository: slotRepository
        )
    }

    func makeBookClientViewModel(slotId: String) -> BookClientViewModel? {
        guard let slot = slots.first(where: { $0.id == slotId }), slot.isBooked == false else { return nil }

        return BookClientViewModel(
            slot: slot,
            clients: directory.clients,
            services: services,
            slotRepository: slotRepository,
            clientRepository: clientRepository
        )
    }

    func makeBookingActionsViewModel(slotId: String) -> BookingActionsViewModel? {
        guard
            directory.isLoaded,
            let slot = slots.first(where: { $0.id == slotId }),
            let clientId = slot.clientId
        else { return nil }

        return BookingActionsViewModel(
            slot: slot,
            client: directory.client(for: clientId),
            services: services,
            slotRepository: slotRepository
        )
    }

    func makeClientCardViewModel(clientId: String) -> ClientCardViewModel {
        ClientCardViewModel(
            clientId: clientId,
            takenHandles: directory.clients.takenHandles,
            clientRepository: clientRepository,
            slotRepository: slotRepository
        )
    }

    func makeSendScheduleViewModel(now: Date = .now) -> SendScheduleViewModel {
        SendScheduleViewModel(
            slots: slots,
            clients: directory.clients,
            now: now
        )
    }

    func makeJumpToDateViewModel(now: Date = .now) -> JumpToDateViewModel {
        JumpToDateViewModel(
            selectedDate: selectedDate,
            datesWithSlots: Set(slots.map(\.date)),
            now: now
        )
    }
}
