import Foundation

struct SlotBookingItem {
    let clientName: String
    let serviceText: String

    init(slot: Slot, clientName: String) {
        self.clientName = clientName
        serviceText = ServiceFormat.summary(name: slot.serviceName, price: slot.servicePrice)
    }
}

struct SlotItem: Identifiable {
    let id: String
    let timeText: String
    let isPast: Bool
    let booking: SlotBookingItem?

    init(slot: Slot, clientName: String, now: Date) {
        id = slot.id ?? Slot.documentId(date: slot.date, time: slot.time)
        timeText = DateFormat.displayTime(slot.time)
        isPast = slot.isPast(now: now)
        booking = slot.isBooked ? SlotBookingItem(slot: slot, clientName: clientName) : nil
    }
}
