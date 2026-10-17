import Foundation
import Observation

@MainActor
@Observable
final class JumpToDateViewModel: Identifiable {
    let id = UUID()

    private var pager: MonthPager

    private let selectedDayId: String
    private let today: String
    private let datesWithSlots: Set<String>

    init(
        selectedDate: Date,
        datesWithSlots: Set<String>,
        now: Date
    ) {
        pager = MonthPager(showing: selectedDate, earliest: Slot.historyStartDate(now: now))
        selectedDayId = DateFormat.date.string(from: selectedDate)
        today = DateFormat.date.string(from: now)
        self.datesWithSlots = datesWithSlots
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

    var weekdays: [MonthWeekday] {
        pager.grid.firstWeek.map { date in
            MonthWeekday(
                id: MonthGrid.column(of: date),
                letter: DateFormat.weekdayLetter.string(from: date).uppercased(),
                name: DateFormat.weekdayName.string(from: date),
                isEnabled: true
            )
        }
    }

    var days: [MonthDay] {
        pager.grid.days.map { date in
            let id = DateFormat.date.string(from: date)

            return MonthDay(
                id: id,
                numberText: DateFormat.dayNumber.string(from: date),
                isEnabled: true,
                isToday: id == today,
                isSelected: id == selectedDayId,
                hasSlots: datesWithSlots.contains(id)
            )
        }
    }

    func showPreviousMonth() {
        pager.showPrevious()
    }

    func showNextMonth() {
        pager.showNext()
    }
}
