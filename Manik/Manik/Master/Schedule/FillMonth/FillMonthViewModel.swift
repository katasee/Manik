import Foundation
import Observation

@MainActor
@Observable
final class FillMonthViewModel: Identifiable {
    let id = UUID()

    private var grid: MonthGrid
    private var selectedDays: Set<String> = []
    private var fillTimes = FillTimes()

    private let currentMonth: MonthGrid
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
        let currentMonth = MonthGrid(containing: now)
        let requested = MonthGrid(containing: month)

        grid = requested.start < currentMonth.start ? currentMonth : requested
        self.currentMonth = currentMonth
        today = DateFormat.date.string(from: now)
        existingIds = Set(existing.map { Slot.documentId(date: $0.date, time: $0.time) })
        datesWithSlots = Set(existing.map(\.date))
        self.now = now
        self.slotRepository = slotRepository
    }

    var monthTitle: String {
        DateFormat.monthYear.string(from: grid.start).capitalized
    }

    var canGoBack: Bool {
        grid != currentMonth
    }

    var leadingBlanks: Int {
        grid.leadingBlanks
    }

    var days: [FillMonthDay] {
        grid.days.map { date in
            let id = DateFormat.date.string(from: date)

            return FillMonthDay(
                id: id,
                numberText: DateFormat.dayNumber.string(from: date),
                isPast: id < today,
                isSelected: selectedDays.contains(id),
                hasSlots: datesWithSlots.contains(id)
            )
        }
    }

    var weekdays: [FillMonthWeekday] {
        grid.days
            .prefix(7)
            .map { date in
                let column = MonthGrid.column(of: date)

                return FillMonthWeekday(
                    id: column,
                    letter: DateFormat.weekdayLetter.string(from: date).uppercased(),
                    name: DateFormat.weekdayName.string(from: date),
                    isEnabled: selectableDays(inColumn: column).isEmpty == false
                )
            }
            .sorted { $0.id < $1.id }
    }

    var times: [FillMonthTime] {
        fillTimes.all.map { time in
            FillMonthTime(
                id: time,
                text: DateFormat.displayTime(time),
                isSelected: fillTimes.selected.contains(time),
                isCustom: fillTimes.isCustom(time)
            )
        }
    }

    var newSlotCount: Int {
        newSlots.count
    }

    func showPreviousMonth() {
        guard canGoBack else { return }

        show(grid.shifted(by: -1))
    }

    func showNextMonth() {
        show(grid.shifted(by: 1))
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

    func add() {
        let slots = newSlots

        guard slots.isEmpty == false else { return }

        try? slotRepository.add(slots)
    }

    private var newSlots: [Slot] {
        Slot.missing(
            days: selectedDays,
            times: fillTimes.selected,
            existingIds: existingIds,
            now: now
        )
    }

    private func show(_ month: MonthGrid) {
        grid = month
        selectedDays = []
    }

    private func selectableDays(inColumn column: Int) -> Set<String> {
        Set(
            grid.days
                .filter { MonthGrid.column(of: $0) == column }
                .map { DateFormat.date.string(from: $0) }
                .filter { $0 >= today }
        )
    }
}
