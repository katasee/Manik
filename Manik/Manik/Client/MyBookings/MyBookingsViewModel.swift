import Foundation
import Observation

@MainActor
@Observable
final class MyBookingsViewModel {
    private static let refreshInterval = 60

    private(set) var sections: [MyBookingSection] = []
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

    func refreshSections() async {
        while Task.isCancelled == false {
            rebuild()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    private func rebuild() {
        sections = MyBookingsList.sections(
            blocks: blocks,
            services: services,
            clientId: clientId,
            now: .now
        )
    }

    private func updateLoaded() {
        hasLoaded = hasBlocks && hasServices
    }
}
