import Foundation
import Observation

@MainActor
@Observable
final class CreateBlockViewModel {
    var date: Date
    var start: ClockTime
    var end: ClockTime
    var selectedServiceIds: Set<String> = []
    var errorMessage: String?
    var isSaving = false

    let services: [Service]

    private let blocks: [Block]
    private let blockRepository: BlockRepository

    init(
        date: Date,
        startHour: Int,
        services: [Service],
        blocks: [Block],
        blockRepository: BlockRepository = FirestoreBlockRepository()
    ) {
        self.date = date
        self.services = services
        self.blocks = blocks
        self.blockRepository = blockRepository

        let dayBlocks = Self.blocks(on: date, from: blocks)
        let startMinutes = Self.firstFreeStart(inHour: startHour, among: dayBlocks)
        self.start = ClockTime(minutesOfDay: startMinutes)
        self.end = ClockTime(minutesOfDay: Self.defaultEnd(after: startMinutes, among: dayBlocks))
    }

    var timeIssue: TimeIssue? {
        if end.minutesOfDay <= start.minutesOfDay { return .endBeforeStart }

        let overlaps = dayBlocks.contains { block in
            block.overlaps(startMinutes: start.minutesOfDay, endMinutes: end.minutesOfDay)
        }

        return overlaps ? .overlap : nil
    }

    var canSubmit: Bool {
        timeIssue == nil && selectedServiceIds.isEmpty == false
    }

    func startDidChange(from oldValue: ClockTime, to newValue: ClockTime) {
        let shifted = end.minutesOfDay + newValue.minutesOfDay - oldValue.minutesOfDay
        end = ClockTime(minutesOfDay: min(max(shifted, WorkHours.openingMinutes), WorkHours.closingMinutes))
    }

    func isSelected(_ service: Service) -> Bool {
        guard let id = service.id else { return false }
        return selectedServiceIds.contains(id)
    }

    func toggleSelection(of service: Service) {
        guard let id = service.id else { return }
        if selectedServiceIds.contains(id) {
            selectedServiceIds.remove(id)
        } else {
            selectedServiceIds.insert(id)
        }
    }

    func submit() async -> Bool {
        guard isSaving == false, canSubmit else { return false }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let block = Block(
            id: nil,
            date: DateFormat.date.string(from: date),
            startTime: DateFormat.storageTime(minutesOfDay: start.minutesOfDay),
            endTime: DateFormat.storageTime(minutesOfDay: end.minutesOfDay),
            offeredServiceIds: Array(selectedServiceIds),
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )

        do {
            try await blockRepository.addBlock(block)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private var dayBlocks: [Block] {
        Self.blocks(on: date, from: blocks)
    }

    private static func blocks(on date: Date, from blocks: [Block]) -> [Block] {
        let day = DateFormat.date.string(from: date)
        return blocks.filter { $0.date == day }
    }

    private static func firstFreeStart(inHour hour: Int, among dayBlocks: [Block]) -> Int {
        let step = WorkHours.slotStepMinutes
        let hourStart = hour * 60

        let freeStart = stride(from: hourStart, to: hourStart + 60, by: step).first { candidate in
            dayBlocks.contains { $0.overlaps(startMinutes: candidate, endMinutes: candidate + step) } == false
        }

        return freeStart ?? hourStart
    }

    private static func defaultEnd(after start: Int, among dayBlocks: [Block]) -> Int {
        let step = WorkHours.slotStepMinutes
        let nextBlockStart = dayBlocks
            .map(\.startMinutes)
            .filter { $0 >= start + step }
            .min() ?? WorkHours.closingMinutes

        return min(
            start + WorkHours.defaultSlotDurationMinutes,
            nextBlockStart / step * step,
            WorkHours.closingMinutes
        )
    }
}
