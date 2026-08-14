import Foundation

enum BookingAvailability {
    static func offers(
        blocks: [Block],
        services: [Service],
        now: Date
    ) -> [ServiceOffer] {
        let upcoming = upcoming(in: blocks, now: now)

        return services
            .compactMap { service in offer(for: service, among: upcoming) }
            .sorted(by: soonestFirst)
    }

    private static func offer(for service: Service, among upcoming: [Block]) -> ServiceOffer? {
        guard let serviceId = service.id else { return nil }

        let slots = upcoming
            .filter { $0.offeredServiceIds.contains(serviceId) }
            .compactMap(slot)

        guard slots.isEmpty == false else { return nil }

        return ServiceOffer(
            id: serviceId,
            service: service,
            slots: slots
        )
    }

    private static func upcoming(in blocks: [Block], now: Date) -> [Block] {
        blocks
            .filter { $0.status == .available }
            .filter { $0.offeredServiceIds.isEmpty == false }
            .filter { block in (block.startsAt.map { $0 > now }) ?? false }
            .sorted { lhs, rhs in
                if lhs.date != rhs.date { return lhs.date < rhs.date }
                if lhs.startMinutes != rhs.startMinutes { return lhs.startMinutes < rhs.startMinutes }

                return (lhs.id ?? "") < (rhs.id ?? "")
            }
    }

    private static func slot(_ block: Block) -> BookingSlot? {
        guard let id = block.id else { return nil }

        return BookingSlot(
            id: id,
            date: block.date,
            startTime: block.startTime
        )
    }

    private static func soonestFirst(_ lhs: ServiceOffer, _ rhs: ServiceOffer) -> Bool {
        guard
            let left = lhs.nearestSlot,
            let right = rhs.nearestSlot
        else { return false }

        if left.date != right.date { return left.date < right.date }
        if left.startTime != right.startTime { return left.startTime < right.startTime }

        return lhs.service.name.localizedStandardCompare(rhs.service.name) == .orderedAscending
    }
}
