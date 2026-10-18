import Foundation

struct ServiceChoice {
    private(set) var selectedId: String?

    private let offered: [Service]
    private let pinned: Service?

    init(services: [Service], pinning slot: Slot? = nil) {
        let offered = services.filter(\.isOffered).sortedByName()

        self.offered = offered
        selectedId = slot?.serviceId
        pinned = slot.flatMap { Self.snapshot(of: $0, outside: offered) }
    }

    var chips: [BookServiceChip] {
        ([pinned].compactMap { $0 } + offered).compactMap { service in
            service.id.map { id in
                BookServiceChip(
                    id: id,
                    title: "\(service.name) · \(ServiceFormat.price(service.price))",
                    isSelected: id == selectedId
                )
            }
        }
    }

    var selectedService: Service? {
        offered.first { $0.id == selectedId }
    }

    mutating func toggle(_ id: String) {
        selectedId = selectedId == id ? nil : id
    }

    private static func snapshot(of slot: Slot, outside offered: [Service]) -> Service? {
        guard
            let id = slot.serviceId,
            offered.contains(where: { $0.id == id }) == false,
            let name = slot.serviceName,
            let price = slot.servicePrice
        else { return nil }

        return Service(id: id, name: name, price: price)
    }
}
