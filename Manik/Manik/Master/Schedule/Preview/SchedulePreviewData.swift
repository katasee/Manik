import Foundation

#if DEBUG
enum SchedulePreviewData {
    static let slots: [Slot] = [
        Slot(id: "slot-0900", date: today, time: "09:00"),
        Slot(id: "slot-1100", date: today, time: "11:00", clientId: "client-olya", serviceId: "svc-classic", serviceName: "Класичний манікюр", servicePrice: 500),
        Slot(id: "slot-1300", date: today, time: "13:00", clientId: "client-kate"),
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
        let directory = ClientDirectory(clients: ClientsPreviewData.clients, isLoaded: true)

        return slots.map { slot in
            SlotItem(
                slot: slot,
                clientName: slot.clientId.map(directory.name(for:)) ?? "",
                now: noon
            )
        }
    }

    static let options: [BookClientOption] = [
        BookClientOption(id: "client-olya", title: "Оля", initial: "О", isSelected: true),
        BookClientOption(id: "client-kate", title: "Катя", initial: "К", isSelected: false)
    ]

    static let serviceChips: [BookServiceChip] = [
        BookServiceChip(id: "svc-classic", title: "Класичний манікюр · 500 zł", isSelected: true),
        BookServiceChip(id: "svc-hybrid", title: "Манікюр гібридний (гель-лак) · 800 zł", isSelected: false)
    ]

    @MainActor
    static var bookClient: BookClientViewModel {
        let viewModel = BookClientViewModel(
            slot: slots[0],
            clients: ClientsPreviewData.clients,
            services: ServicesPreviewData.services,
            slotRepository: FakeSlotRepository(slots: slots),
            clientRepository: FakeClientRepository(clients: ClientsPreviewData.clients)
        )

        viewModel.searchText = "о"
        viewModel.toggleClient("client-olya")
        viewModel.toggleService("svc-classic")

        return viewModel
    }

    @MainActor
    static var bookingActions: BookingActionsViewModel {
        BookingActionsViewModel(
            slot: slots[1],
            client: ClientsPreviewData.clients.first,
            services: ServicesPreviewData.services,
            slotRepository: FakeSlotRepository(slots: slots)
        )
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

    @MainActor
    static var jumpToDate: JumpToDateViewModel {
        JumpToDateViewModel(
            selectedDate: .now,
            datesWithSlots: [today],
            now: .now
        )
    }

    static let sendScheduleDays: [(day: Int, times: [String])] = [
        (1, ["09:00", "11:00", "13:00", "16:00"]), (2, ["09:00", "11:00", "13:00"]), (5, ["14:00", "19:00"]),
        (6, ["11:00", "13:00"]), (7, ["12:00", "14:00"]), (8, ["11:30", "13:30", "16:30"]),
        (9, ["09:00", "11:00", "13:00"]), (12, ["12:00", "14:00"]), (13, ["09:00", "11:00", "13:00"]),
        (14, ["12:00", "14:00", "19:00"]), (16, ["09:00", "11:00", "13:00"]), (17, ["11:30"]),
        (19, ["12:00", "14:00", "17:00", "19:00"]), (20, ["09:00", "13:00"]), (21, ["12:00", "14:00"]),
        (22, ["09:00", "11:00", "13:00", "16:00"]), (23, ["11:00", "13:00", "16:00"]), (24, ["09:30"]),
        (26, ["12:00", "14:00", "17:00", "19:00"]), (27, ["11:00", "13:00"]), (28, ["12:00", "14:00"])
    ]

    static var sendScheduleSlots: [Slot] {
        let freeSlots = sendScheduleDays.flatMap { day, times in
            times.map { time in
                Slot(id: "send-\(day)-\(time)", date: dayId(day), time: time)
            }
        }

        return freeSlots + [Slot(id: "send-booked", date: dayId(5), time: "11:00", clientId: "client-olya")]
    }

    @MainActor
    static var sendSchedule: SendScheduleViewModel {
        SendScheduleViewModel(
            slots: sendScheduleSlots,
            clients: ClientsPreviewData.clients,
            now: monthStart
        )
    }

    private static var today: String {
        DateFormat.date.string(from: .now)
    }

    private static var monthStart: Date {
        MonthGrid(containing: .now).start
    }

    private static func dayId(_ day: Int) -> String {
        let date = DateFormat.salonCalendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart

        return DateFormat.date.string(from: date)
    }

    private static var noon: Date {
        DateFormat.dateTime.date(from: "\(today) 12:00") ?? .now
    }
}
#endif
