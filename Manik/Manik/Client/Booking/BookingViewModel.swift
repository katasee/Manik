import Foundation
import Observation

@MainActor
@Observable
final class BookingViewModel {
    private static let refreshInterval = 60

    private(set) var offers: [ServiceOffer] = []
    private(set) var nearestSlot: BookingSlot?
    private(set) var hasLoaded = false

    private let clientId: String
    private let blockRepository: BlockRepository
    private let serviceRepository: ServiceRepository

    private var hasBlocks = false
    private var hasServices = false

    private var blocks: [Block] = [] {
        didSet { rebuild() }
    }

    private var services: [Service] = [] {
        didSet { rebuild() }
    }

    init(
        clientId: String,
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository()
    ) {
        self.clientId = clientId
        self.blockRepository = blockRepository
        self.serviceRepository = serviceRepository
    }

    func makeDatesViewModel(for offer: ServiceOffer) -> BookingDatesViewModel {
        BookingDatesViewModel(
            offer: offer,
            clientId: clientId,
            blockRepository: blockRepository
        )
    }

    func makeConfirmViewModel(context: BookingConfirmContext) -> BookingConfirmViewModel {
        BookingConfirmViewModel(
            context: context,
            clientId: clientId,
            blockRepository: blockRepository
        )
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks
            hasBlocks = true
            updateLoaded()
        }
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices
            hasServices = true
            updateLoaded()
        }
    }

    func refreshAvailability() async {
        while Task.isCancelled == false {
            rebuild()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    private func rebuild() {
        let now = Date.now

        offers = BookingAvailability.offers(
            blocks: blocks,
            services: services,
            now: now
        )

        nearestSlot = offers.first?.nearestSlot
    }

    private func updateLoaded() {
        hasLoaded = hasBlocks && hasServices
    }
}
