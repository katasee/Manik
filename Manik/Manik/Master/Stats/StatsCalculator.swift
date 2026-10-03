import Foundation

struct MonthlyTotals {
    let revenue: Int
    let previousRevenue: Int
    let expected: Int
    let visits: Int
    let minutes: Int
    let clients: Int
    let previousClients: Int
    let freeSlots: Int
    let isMonthFinished: Bool
}

enum StatsCalculator {
    static func monthStart(containing date: Date) -> Date {
        let calendar = DateFormat.salonCalendar
        let components = calendar.dateComponents([.year, .month], from: date)

        return calendar.date(from: components) ?? date
    }

    static func totals(
        blocks: [Block],
        monthStart: Date,
        now: Date
    ) -> MonthlyTotals {
        let calendar = DateFormat.salonCalendar
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        let previousStart = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart

        let monthBlocks = blocks.filter { isInside($0, start: monthStart, end: monthEnd) }
        let previousBlocks = blocks.filter { isInside($0, start: previousStart, end: monthStart) }

        let completed = monthBlocks.filter { $0.isCompleted(now: now) }
        let previousCompleted = previousBlocks.filter { $0.isCompleted(now: now) }

        let isMonthFinished = monthEnd <= now

        return MonthlyTotals(
            revenue: total(of: completed),
            previousRevenue: total(of: previousCompleted),
            expected: total(of: monthBlocks.filter { $0.status == .confirmed }),
            visits: completed.count,
            minutes: minutes(of: completed),
            clients: clientIds(of: completed).count,
            previousClients: clientIds(of: previousCompleted).count,
            freeSlots: freeSlots(
                in: monthBlocks,
                isMonthFinished: isMonthFinished,
                now: now
            ),
            isMonthFinished: isMonthFinished
        )
    }

    private static func isInside(
        _ block: Block,
        start: Date,
        end: Date
    ) -> Bool {
        guard let startsAt = block.startsAt else { return false }

        return startsAt >= start && startsAt < end
    }

    private static func total(of blocks: [Block]) -> Int {
        blocks.reduce(0) { $0 + ($1.bookedServicePrice ?? 0) }
    }

    private static func clientIds(of blocks: [Block]) -> Set<String> {
        Set(blocks.compactMap(\.clientId))
    }

    private static func minutes(of blocks: [Block]) -> Int {
        blocks.reduce(0) { $0 + max(0, $1.endMinutes - $1.startMinutes) }
    }

    private static func freeSlots(
        in blocks: [Block],
        isMonthFinished: Bool,
        now: Date
    ) -> Int {
        blocks.filter { block in
            guard block.status == .available else { return false }
            guard isMonthFinished == false else { return true }
            guard let startsAt = block.startsAt else { return false }

            return startsAt > now
        }
        .count
    }
}
