struct ServiceOffer: Identifiable, Hashable {
    let id: String
    let service: Service
    let slots: [BookingSlot]

    var nearestSlot: BookingSlot? { slots.first }

    var nearestDaySlots: [BookingSlot] {
        guard let nearest = nearestSlot else { return [] }

        return slots.filter { $0.date == nearest.date }
    }

    static func == (lhs: ServiceOffer, rhs: ServiceOffer) -> Bool {
        lhs.id == rhs.id && lhs.slots == rhs.slots
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
