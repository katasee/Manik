import Foundation
import Observation

@MainActor
@Observable
final class FillMonthViewModel: Identifiable {
    let id = UUID()

    private var pager: MonthPager
    private var selectedDays: Set<String> = []
    private var fillTimes = FillTimes()

    private let today: String
    private let existingIds: Set<String>
    private let datesWithSlots: Set<String>
    private let now: Date
    private let slotRepository: SlotRepository

    init(
        month: Date,
        existing: [Slot],
        now: Date,
        slotRepository: SlotRepository
    ) {
        pager = MonthPager(showing: month, earliest: now)
        today = DateFormat.date.string(from: now)
        existingIds = Set(existing.map { Slot.documentId(date: $0.date, time: $0.time) })
        datesWithSlots = Set(existing.map(\.date))
        self.now = now
        self.slotRepository = slotRepository
    }

    var monthTitle: String {
        DateFormat.monthYear.string(from: pager.grid.start).capitalized
    }

    var canGoBack: Bool {
        pager.canGoBack
    }

    var leadingBlanks: Int {
        pager.grid.leadingBlanks
    }

    var days: [MonthDay] {
        pager.grid.days.map { date in
            let id = DateFormat.date.string(from: date)

            return MonthDay(
                id: id,
                numberText: DateFormat.dayNumber.string(from: date),
                isEnabled: id >= today,
                isToday: id == today,
                isSelected: selectedDays.contains(id),
                hasSlots: datesWithSlots.contains(id)
            )
        }
    }

    var weekdays: [MonthWeekday] {
        pager.grid.firstWeek.map { date in
            let column = MonthGrid.column(of: date)

            return MonthWeekday(
                id: column,
                letter: DateFormat.weekdayLetter.string(from: date).uppercased(),
                name: DateFormat.weekdayName.string(from: date),
                isEnabled: selectableDays(inColumn: column).isEmpty == false
            )
        }
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

    func showPreviousMonth() {
        if pager.showPrevious() {
            selectedDays = []
        }
    }

    func showNextMonth() {
        pager.showNext()
        selectedDays = []
    }

    func toggleDay(_ id: String) {
        guard id >= today else { return }

        if selectedDays.remove(id) == nil {
            selectedDays.insert(id)
        }
    }

    func toggleWeekday(_ column: Int) {
        let days = selectableDays(inColumn: column)

        if days.isSubset(of: selectedDays) {
            selectedDays.subtract(days)
        } else {
            selectedDays.formUnion(days)
        }
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
            days: selectedDays,
            times: fillTimes.selected,
            existingIds: existingIds,
            now: now
        )
    }

    private func selectableDays(inColumn column: Int) -> Set<String> {
        Set(
            pager.grid.days
                .filter { MonthGrid.column(of: $0) == column }
                .map { DateFormat.date.string(from: $0) }
                .filter { $0 >= today }
        )
    }
}
