import Foundation

struct MonthlyStats {
    let revenueLabel: String
    let expectedLabel: String?
    let revenueTrend: StatsTrend?
    let visitsLabel: String
    let hoursLabel: String
    let clientsLabel: String
    let clientsTrend: StatsTrend?
    let freeSlotsLabel: String
    let isMonthFinished: Bool

    init(totals: MonthlyTotals) {
        revenueLabel = ServiceFormat.price(totals.revenue)
        expectedLabel = totals.isMonthFinished
            ? nil
            : ServiceFormat.price(totals.expected)
        revenueTrend = StatsTrend.percent(
            current: totals.revenue,
            previous: totals.previousRevenue
        )
        visitsLabel = totals.visits.formatted()
        hoursLabel = (Double(totals.minutes) / 60)
            .formatted(.number.precision(.fractionLength(0...1)))
        clientsLabel = totals.clients.formatted()
        clientsTrend = StatsTrend.count(
            current: totals.clients,
            previous: totals.previousClients
        )
        freeSlotsLabel = totals.freeSlots.formatted()
        isMonthFinished = totals.isMonthFinished
    }
}
