import Foundation
import Observation

@MainActor
@Observable
final class FillMonthViewModel: Identifiable {
    let id = UUID()

    var days: MonthDaySelection

    private var fillTimes = FillTimes()

    private let existingIds: Set<String>
    private let now: Date
    private let slotRepository: SlotRepository

    init(
        month: Date,
        existing: [Slot],
        now: Date,
        slotRepository: SlotRepository
    ) {
        days = MonthDaySelection(
            month: month,
            now: now,
            markedDays: Set(existing.map(\.date))
        )
        existingIds = Set(existing.map { Slot.documentId(date: $0.date, time: $0.time) })
        self.now = now
        self.slotRepository = slotRepository
    }

    var times: [TimeChipItem] {
        fillTimes.all.map { time in
            TimeChipItem(
                id: time,
                text: DateFormat.displayTime(time),
                isSelected: fillTimes.selected.contains(time),
                isCustom: fillTimes.isCustom(time)
            )
        }
    }

    var newSlotCount: Int {
        missingSlots(now: now).count
    }

    func toggleTime(_ id: String) {
        fillTimes.toggle(id)
    }

    func addCustomTime(_ time: ClockTime) {
        fillTimes.addCustom(DateFormat.storageTime(minutesOfDay: time.minutesOfDay))
    }

    func removeCustomTime(_ id: String) {
        fillTimes.removeCustom(id)
    }

    func add(now: Date = .now) {
        let slots = missingSlots(now: now)

        guard slots.isEmpty == false else { return }

        try? slotRepository.add(slots)
    }

    private func missingSlots(now: Date) -> [Slot] {
        Slot.missing(
            days: days.selected,
            times: fillTimes.selected,
            existingIds: existingIds,
            now: now
        )
    }
}
