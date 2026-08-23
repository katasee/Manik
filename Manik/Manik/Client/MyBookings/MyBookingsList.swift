import Foundation

enum MyBookingsList {
    static let pastLimit = 5

    static func sections(
        blocks: [Block],
        clientId: String,
        now: Date
    ) -> [MyBookingSection] {
        let owned = blocks
            .filter { $0.clientId == clientId }
            .filter { $0.status != .available }

        let upcoming = owned
            .filter { isUpcoming($0, now: now) }
            .sorted(by: Block.chronologically)
            .map { booking($0, isPast: false) }

        let past = owned
            .filter { isUpcoming($0, now: now) == false }
            .sorted { Block.chronologically($1, $0) }
            .prefix(pastLimit)
            .map { booking($0, isPast: true) }

        return [
            MyBookingSection(kind: .upcoming, bookings: upcoming),
            MyBookingSection(kind: .past, bookings: Array(past))
        ]
        .filter { $0.bookings.isEmpty == false }
    }

    private static func isUpcoming(_ block: Block, now: Date) -> Bool {
        (block.startsAt.map { $0 > now }) ?? false
    }

    private static func booking(_ block: Block, isPast: Bool) -> MyBooking {
        MyBooking(
            id: block.id ?? "\(block.date)-\(block.startTime)",
            cancelId: isPast ? nil : block.id,
            serviceName: block.bookedServiceLabel,
            dayLabel: dayLabel(for: block),
            timeRangeLabel: block.timeRangeLabel,
            priceLabel: block.bookedServicePrice.map { ServiceFormat.price($0) },
            status: block.status,
            isPast: isPast
        )
    }

    private static func dayLabel(for block: Block) -> String {
        guard let day = DateFormat.date.date(from: block.date) else { return block.date }

        return DateFormat.dayMonth.string(from: day)
    }
}
