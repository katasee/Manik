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

    static func month(
        startingAt monthStart: Date,
        for offer: ServiceOffer,
        now: Date
    ) -> BookingMonth {
        let calendar = DateFormat.salonCalendar
        let start = startOfMonth(monthStart, in: calendar)
        let gridStart = calendar.dateInterval(of: .weekOfYear, for: start)?.start ?? start
        let dates = (0..<gridLength).compactMap {
            calendar.date(byAdding: .day, value: $0, to: gridStart)
        }
        let availableDates = Set(offer.slots.map(\.date))
        let today = calendar.startOfDay(for: now)

        return BookingMonth(
            start: start,
            title: DateFormat.monthYear.string(from: start),
            weekdaySymbols: dates.prefix(daysPerWeek).map(weekdaySymbol),
            days: dates.map { date in
                day(
                    date,
                    in: start,
                    availableDates: availableDates,
                    today: today,
                    calendar: calendar
                )
            },
            canGoBack: start > startOfMonth(now, in: calendar)
        )
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

    static let daysPerWeek = 7

    private static let gridLength = 42

    private static func day(
        _ date: Date,
        in monthStart: Date,
        availableDates: Set<String>,
        today: Date,
        calendar: Calendar
    ) -> BookingDay {
        let key = DateFormat.date.string(from: date)

        return BookingDay(
            date: key,
            numberLabel: DateFormat.dayNumber.string(from: date),
            isInMonth: calendar.isDate(
                date,
                equalTo: monthStart,
                toGranularity: .month
            ),
            isAvailable: availableDates.contains(key),
            isPast: date < today
        )
    }

    private static func startOfMonth(_ date: Date, in calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)

        return calendar.date(from: components) ?? date
    }

    private static func weekdaySymbol(_ date: Date) -> String {
        DateFormat.weekdayLetter.string(from: date).uppercased()
    }
}
