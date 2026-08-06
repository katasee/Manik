import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    var selectedDate = Date.now {
        didSet { rebuildSchedule() }
    }

    var deletionFailed = false

    private(set) var scheduledBlocks: [ScheduledBlock] = []
    private(set) var freeHours: Set<Int> = []
    private(set) var services: [Service] = []

    private var blocks: [Block] = [] {
        didSet { rebuildSchedule() }
    }

    private let blockRepository: BlockRepository
    private let serviceRepository: ServiceRepository

    init(
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository()
    ) {
        self.blockRepository = blockRepository
        self.serviceRepository = serviceRepository
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks
        }
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices
            rebuildSchedule()
        }
    }

    func delete(_ block: Block) async {
        guard let blockId = block.id else { return }

        do {
            try await blockRepository.deleteBlock(blockId: blockId)
        } catch {
            deletionFailed = true
        }
    }

    private func rebuildSchedule() {
        let dateString = DateFormat.date.string(from: selectedDate)
        let todaysBlocks = blocks
            .filter { $0.date == dateString }
            .sorted(by: Self.chronologically)

        scheduledBlocks = cascade(todaysBlocks)
        freeHours = Set(SalonHours.working.filter { isFree($0, among: todaysBlocks) })
    }

    private func cascade(_ ordered: [Block]) -> [ScheduledBlock] {
        ordered.enumerated().map { index, block in
            let depth = ordered[..<index].filter { earlier in
                earlier.startMinutes < block.endMinutes && earlier.endMinutes > block.startMinutes
            }.count

            return ScheduledBlock(
                block: block,
                depth: depth,
                serviceNames: serviceNames(for: block)
            )
        }
    }

    private func isFree(_ hour: Int, among todaysBlocks: [Block]) -> Bool {
        let hourStart = hour * 60
        let hourEnd = hourStart + 60

        let occupied = todaysBlocks.reduce(0) { total, block in
            total + max(min(block.endMinutes, hourEnd) - max(block.startMinutes, hourStart), 0)
        }

        return occupied <= SalonHours.freeSlotToleranceMinutes
    }

    private func serviceNames(for block: Block) -> String {
        block.offeredServiceIds
            .compactMap { serviceId in services.first { $0.id == serviceId }?.name }
            .joined(separator: ", ")
    }

    private static func chronologically(_ lhs: Block, _ rhs: Block) -> Bool {
        lhs.startMinutes == rhs.startMinutes
            ? (lhs.id ?? "") < (rhs.id ?? "")
            : lhs.startMinutes < rhs.startMinutes
    }
}
