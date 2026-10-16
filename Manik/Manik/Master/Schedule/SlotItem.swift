import Foundation

struct SlotItem: Identifiable {
    let id: String
    let timeText: String
    let isPast: Bool

    init(slot: Slot, now: Date) {
        id = slot.id ?? "\(slot.date)_\(slot.time)"
        timeText = DateFormat.displayTime(slot.time)
        isPast = slot.isPast(now: now)
    }
}
