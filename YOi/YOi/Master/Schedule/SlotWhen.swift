import Foundation

enum SlotWhen {
    static func text(for slot: Slot) -> String {
        let day = DateFormat.date
            .date(from: slot.date)
            .map(DateFormat.weekdayDayMonth.string(from:)) ?? slot.date

        return "\(day) · \(DateFormat.displayTime(slot.time))"
    }
}
