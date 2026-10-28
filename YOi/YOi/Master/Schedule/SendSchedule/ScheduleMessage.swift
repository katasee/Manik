import Foundation

enum ScheduleMessage {
    static func text(
        slots: [Slot],
        month: MonthGrid,
        now: Date
    ) -> String? {
        let monthStart = DateFormat.date.string(from: month.start)
        let nextMonthStart = DateFormat.date.string(from: month.shifted(by: 1).start)
        let monthRange = monthStart..<nextMonthStart
        
        let offeredSlots = slots.filter { slot in
            monthRange.contains(slot.date) && slot.isBookable(now: now)
        }
        
        let dayTexts = Dictionary(grouping: offeredSlots, by: \.date)
            .sorted { $0.key < $1.key }
            .compactMap { dayId, daySlots in
                dayText(dayId: dayId, times: daySlots.map(\.time).sorted())
            }
        
        return dayTexts.isEmpty ? nil : dayTexts.joined(separator: "\n")
    }
    
    private static func dayText(dayId: String, times: [String]) -> String? {
        guard let day = DateFormat.date.date(from: dayId) else { return nil }
        
        let messageTimes = times.compactMap { time in
            DateFormat.time.date(from: time).map { DateFormat.messageTime.string(from: $0) }
        }
        
        guard messageTimes.isEmpty == false else { return nil }
        
        return DateFormat.messageDay.string(from: day) + "-" + messageTimes.joined(separator: "/")
    }
}
