import Foundation

struct SlotBookingItem {
    let clientName: String
    let serviceText: String

    init(slot: Slot, clientName: String) {
        self.clientName = clientName

        if let serviceName = slot.serviceName, let servicePrice = slot.servicePrice {
            serviceText = "\(serviceName) · \(ServiceFormat.price(servicePrice))"
        } else {
            serviceText = String(localized: "schedule.slot.noService")
        }
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
