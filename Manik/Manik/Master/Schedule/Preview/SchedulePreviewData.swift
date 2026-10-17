import Foundation

#if DEBUG
enum SchedulePreviewData {
    static let slots: [Slot] = [
        Slot(id: "slot-0900", date: today, time: "09:00"),
        Slot(id: "slot-1100", date: today, time: "11:00"),
        Slot(id: "slot-1300", date: today, time: "13:00"),
        Slot(id: "slot-1600", date: today, time: "16:00")
    ]

    static let dayStates: [FillMonthDay] = [
        FillMonthDay(id: "past", numberText: "12", isPast: true, isSelected: false, hasSlots: true),
        FillMonthDay(id: "plain", numberText: "18", isPast: false, isSelected: false, hasSlots: false),
        FillMonthDay(id: "slots", numberText: "19", isPast: false, isSelected: false, hasSlots: true),
        FillMonthDay(id: "selected", numberText: "20", isPast: false, isSelected: true, hasSlots: false),
        FillMonthDay(id: "both", numberText: "26", isPast: false, isSelected: true, hasSlots: true)
    ]

    static var items: [SlotItem] {
        slots.map { SlotItem(slot: $0, now: noon) }
    }

    @MainActor
    static var fillMonth: FillMonthViewModel {
        let viewModel = FillMonthViewModel(
            month: .now,
            existing: slots,
            now: .now,
            slotRepository: FakeSlotRepository(slots: slots)
        )

        viewModel.toggleWeekday(MonthGrid.column(of: .now))
        viewModel.toggleTime("12:00")
        viewModel.toggleTime("14:00")
        viewModel.addCustomTime(ClockTime(minutesOfDay: 17 * 60 + 30))

        return viewModel
    }

    private static var today: String {
        DateFormat.date.string(from: .now)
    }

    private static var noon: Date {
        DateFormat.dateTime.date(from: "\(today) 12:00") ?? .now
    }
}
#endif
