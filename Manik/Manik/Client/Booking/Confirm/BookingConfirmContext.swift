struct BookingConfirmContext: Identifiable {
    let service: Service
    let slot: BookingSlot

    var id: String { slot.id }
}
