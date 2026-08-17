import Foundation

enum MyBookingsList {
    static let pastLimit = 5

    static func sections(
        blocks: [Block],
        services: [Service],
        clientId: String,
        now: Date
    ) -> [MyBookingSection] {
        let owned = blocks
            .filter { $0.clientId == clientId }
            .filter { $0.status != .available }

        let upcoming = owned
            .filter { isUpcoming($0, now: now) }
            .sorted(by: chronologically)
            .map { booking($0, services: services, isPast: false) }

        let past = owned
            .filter { isUpcoming($0, now: now) == false }
            .sorted { chronologically($1, $0) }
            .prefix(pastLimit)
            .map { booking($0, services: services, isPast: true) }

        return [
            MyBookingSection(kind: .upcoming, bookings: upcoming),
            MyBookingSection(kind: .past, bookings: Array(past))
        ]
        .filter { $0.bookings.isEmpty == false }
    }

    private static func isUpcoming(_ block: Block, now: Date) -> Bool {
        (block.startsAt.map { $0 > now }) ?? false
    }

    private static func booking(
        _ block: Block,
        services: [Service],
        isPast: Bool
    ) -> MyBooking {
        let service = services.first { $0.id == block.bookedServiceId }

        return MyBooking(
            id: block.id ?? "\(block.date)-\(block.startTime)",
            cancelId: isPast ? nil : block.id,
            serviceName: service?.name ?? String(localized: "common.service.unknown"),
            dayLabel: dayLabel(for: block),
            timeRangeLabel: block.timeRangeLabel,
            priceLabel: service.map { ServiceFormat.price($0.price) },
            status: block.status,
            isPast: isPast
        )
    }

    private static func dayLabel(for block: Block) -> String {
        guard let day = DateFormat.date.date(from: block.date) else { return block.date }

        return DateFormat.dayMonth.string(from: day)
    }

    private static func chronologically(_ lhs: Block, _ rhs: Block) -> Bool {
        if lhs.date != rhs.date { return lhs.date < rhs.date }
        if lhs.startMinutes != rhs.startMinutes { return lhs.startMinutes < rhs.startMinutes }

        return (lhs.id ?? "") < (rhs.id ?? "")
    }
}
