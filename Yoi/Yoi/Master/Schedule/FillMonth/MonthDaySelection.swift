import Foundation

struct MonthDaySelection {
    private(set) var selected: Set<String> = []

    private var pager: MonthPager
    private let today: String
    private let markedDays: Set<String>

    init(month: Date, now: Date, markedDays: Set<String>) {
        pager = MonthPager(showing: month, earliest: now)
        today = DateFormat.date.string(from: now)
        self.markedDays = markedDays
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

    func days(conflicts: [String: PlanConflict]) -> [MonthDay] {
        pager.grid.days.map { date in
            let id = DateFormat.date.string(from: date)

            return MonthDay(
                id: id,
                numberText: DateFormat.dayNumber.string(from: date),
                isEnabled: id >= today,
                isToday: id == today,
                isSelected: selected.contains(id),
                hasSlots: markedDays.contains(id),
                conflict: conflicts[id]
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

    mutating func showPrevious() {
        if pager.showPrevious() {
            selected = []
        }
    }

    mutating func showNext() {
        pager.showNext()
        selected = []
    }

    mutating func toggleDay(_ id: String) {
        guard id >= today else { return }

        if selected.remove(id) == nil {
            selected.insert(id)
        }
    }

    mutating func toggleWeekday(_ column: Int) {
        let days = selectableDays(inColumn: column)

        if days.isSubset(of: selected) {
            selected.subtract(days)
        } else {
            selected.formUnion(days)
        }
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
