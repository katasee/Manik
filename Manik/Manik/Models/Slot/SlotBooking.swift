struct SlotBooking: Equatable {
    let clientId: String
    let serviceId: String?
    let serviceName: String?
    let servicePrice: Int?

    init(clientId: String, service: Service?) {
        self.clientId = clientId
        serviceId = service?.id
        serviceName = service?.name
        servicePrice = service?.price
    }

    init?(bookedSlot slot: Slot) {
        guard let clientId = slot.clientId else { return nil }

        self.clientId = clientId
        serviceId = slot.serviceId
        serviceName = slot.serviceName
        servicePrice = slot.servicePrice
    }
}
