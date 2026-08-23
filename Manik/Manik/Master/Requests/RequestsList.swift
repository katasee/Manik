import Foundation

enum RequestsList {
    static func requests(
        blocks: [Block],
        services: [Service],
        clientNames: [String: String],
        unreadableClientIds: Set<String>,
        now: Date
    ) -> [BookingRequest] {
        pending(in: blocks, now: now)
            .sorted(by: Block.chronologically)
            .compactMap {
                request(
                    $0,
                    services: services,
                    clientNames: clientNames,
                    unreadableClientIds: unreadableClientIds
                )
            }
    }

    static func pendingClientIds(in blocks: [Block], now: Date) -> Set<String> {
        Set(pending(in: blocks, now: now).compactMap(\.clientId))
    }

    private static func pending(in blocks: [Block], now: Date) -> [Block] {
        blocks
            .filter { $0.status == .pending }
            .filter { isUpcoming($0, now: now) }
    }

    private static func isUpcoming(_ block: Block, now: Date) -> Bool {
        (block.startsAt.map { $0 > now }) ?? false
    }

    private static func request(
        _ block: Block,
        services: [Service],
        clientNames: [String: String],
        unreadableClientIds: Set<String>
    ) -> BookingRequest? {
        guard let id = block.id,
              let clientId = block.clientId,
              let clientName = name(
                  of: clientId,
                  clientNames: clientNames,
                  unreadableClientIds: unreadableClientIds
              ) else { return nil }

        let service = services.first { $0.id == block.bookedServiceId }

        return BookingRequest(
            id: id,
            clientName: clientName,
            serviceName: service?.name ?? String(localized: "common.service.unknown"),
            dayLabel: dayLabel(for: block),
            timeRangeLabel: block.timeRangeLabel,
            priceLabel: service.map { ServiceFormat.price($0.price) }
        )
    }

    private static func name(
        of clientId: String,
        clientNames: [String: String],
        unreadableClientIds: Set<String>
    ) -> String? {
        if let name = clientNames[clientId] { return name }

        guard unreadableClientIds.contains(clientId) else { return nil }

        return String(localized: "requests.client.unavailable")
    }

    private static func dayLabel(for block: Block) -> String {
        guard let day = DateFormat.date.date(from: block.date) else { return block.date }

        return DateFormat.dayMonth.string(from: day)
    }
}
