import Foundation

#if DEBUG
enum SchedulePreviewData {
    static let slots: [Slot] = [
        Slot(id: "slot-0900", date: today, time: "09:00"),
        Slot(id: "slot-1100", date: today, time: "11:00"),
        Slot(id: "slot-1300", date: today, time: "13:00"),
        Slot(id: "slot-1600", date: today, time: "16:00")
    ]

    static var items: [SlotItem] {
        slots.map { SlotItem(slot: $0, now: noon) }
    }

    private static var today: String {
        DateFormat.date.string(from: .now)
    }

    private static var noon: Date {
        DateFormat.dateTime.date(from: "\(today) 12:00") ?? .now
    }
}
#endif
