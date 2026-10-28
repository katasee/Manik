import Foundation

struct MonthlyTotals {
    let revenue: Int
    let previousRevenue: Int?
    let expected: Int
    let visits: Int
    let clients: Int
    let previousClients: Int?
    let freeSlots: Int
    let windows: Int
    let bookedWindows: Int
    let isMonthFinished: Bool
}

enum StatsCalculator {
    static func monthStart(containing date: Date) -> Date {
        let calendar = DateFormat.salonCalendar
        let components = calendar.dateComponents([.year, .month], from: date)

        return calendar.date(from: components) ?? date
    }

    static func earliestMonthStart(now: Date) -> Date {
        let historyStart = Slot.historyStartDate(now: now)
        let start = monthStart(containing: historyStart)

        guard start < historyStart else { return start }

        return DateFormat.salonCalendar.date(byAdding: .month, value: 1, to: start) ?? start
    }

    static func totals(
        slots: [Slot],
        monthStart: Date,
        now: Date
    ) -> MonthlyTotals {
        let calendar = DateFormat.salonCalendar
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        let previousStart = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart
        let hasPrevious = previousStart >= earliestMonthStart(now: now)

        let monthSlots = slots.filter { isInside($0, start: monthStart, end: monthEnd) }
        let previousSlots = slots.filter { isInside($0, start: previousStart, end: monthStart) }

        let booked = monthSlots.filter(\.isBooked)
        let completed = booked.filter { $0.isPast(now: now) }
        let previousCompleted = previousSlots.filter { $0.isBooked && $0.isPast(now: now) }

        let isMonthFinished = monthEnd <= now

        return MonthlyTotals(
            revenue: total(of: completed),
            previousRevenue: hasPrevious ? total(of: previousCompleted) : nil,
            expected: total(of: booked),
            visits: completed.count,
            clients: clientIds(of: completed).count,
            previousClients: hasPrevious ? clientIds(of: previousCompleted).count : nil,
            freeSlots: freeSlots(
                in: monthSlots,
                isMonthFinished: isMonthFinished,
                now: now
            ),
            windows: monthSlots.count,
            bookedWindows: booked.count,
            isMonthFinished: isMonthFinished
        )
    }

    private static func isInside(
        _ slot: Slot,
        start: Date,
        end: Date
    ) -> Bool {
        guard let startsAt = slot.startsAt else { return false }

        return startsAt >= start && startsAt < end
    }

    private static func total(of slots: [Slot]) -> Int {
        slots.reduce(0) { $0 + ($1.servicePrice ?? 0) }
    }

    private static func clientIds(of slots: [Slot]) -> Set<String> {
        Set(slots.compactMap(\.clientId))
    }

    private static func freeSlots(
        in slots: [Slot],
        isMonthFinished: Bool,
        now: Date
    ) -> Int {
        slots.count { slot in
            guard slot.isBooked == false else { return false }

            return isMonthFinished || slot.isPast(now: now) == false
        }
    }
}
