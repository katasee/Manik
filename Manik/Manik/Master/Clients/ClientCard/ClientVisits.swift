import Foundation

struct ClientVisitItem: Identifiable {
    let id: String
    let dateText: String
    let timeText: String
    let serviceText: String

    init(slot: Slot) {
        id = slot.id ?? Slot.documentId(date: slot.date, time: slot.time)
        dateText = DateFormat.date.date(from: slot.date).map(DateFormat.dayMonth.string(from:)) ?? slot.date
        timeText = DateFormat.displayTime(slot.time)
        serviceText = ServiceFormat.summary(name: slot.serviceName, price: slot.servicePrice)
    }
}

struct ClientVisits {
    let planned: [ClientVisitItem]
    let history: [ClientVisitItem]

    init(slots: [Slot], now: Date) {
        let sorted = slots.sorted(by: Slot.chronologically)

        planned = sorted
            .filter { $0.isPast(now: now) == false }
            .map(ClientVisitItem.init)
        history = sorted
            .filter { $0.isPast(now: now) }
            .reversed()
            .map(ClientVisitItem.init)
    }
}
