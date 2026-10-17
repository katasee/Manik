import Foundation

#if DEBUG
enum SchedulePreviewData {
    static let slots: [Slot] = [
        Slot(id: "slot-0900", date: today, time: "09:00"),
        Slot(id: "slot-1100", date: today, time: "11:00"),
        Slot(id: "slot-1300", date: today, time: "13:00"),
        Slot(id: "slot-1600", date: today, time: "16:00")
    ]

    static let dayStates: [MonthDay] = [
        MonthDay(id: "past", numberText: "12", isEnabled: false, isToday: false, isSelected: false, hasSlots: true),
        MonthDay(id: "today", numberText: "17", isEnabled: true, isToday: true, isSelected: false, hasSlots: false),
        MonthDay(id: "slots", numberText: "19", isEnabled: true, isToday: false, isSelected: false, hasSlots: true),
        MonthDay(id: "selected", numberText: "20", isEnabled: true, isToday: false, isSelected: true, hasSlots: false),
        MonthDay(id: "both", numberText: "26", isEnabled: true, isToday: false, isSelected: true, hasSlots: true)
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
