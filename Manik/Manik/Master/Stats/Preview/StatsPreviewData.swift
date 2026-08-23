import Foundation

#if DEBUG
enum StatsPreviewData {
    static let reference = Date.now

    static let blocks: [Block] = [
        block(id: "done-1", day: 2, start: "10:00", end: "11:30", price: 450, client: "client-olena", status: .confirmed),
        block(id: "done-2", day: 4, start: "12:00", end: "13:00", price: 750, client: "client-maria", status: .confirmed),
        block(id: "done-3", day: 6, start: "14:00", end: "15:30", price: 600, client: "client-olena", status: .confirmed),
        block(id: "done-legacy", day: 7, start: "16:00", end: "17:00", price: nil, client: "client-sofia", status: .confirmed),
        block(id: "upcoming-1", day: 27, start: "10:00", end: "11:00", price: 750, client: "client-maria", status: .confirmed),
        block(id: "pending-1", day: 26, start: "12:00", end: "13:00", price: 450, client: "client-sofia", status: .pending),
        block(id: "free-1", day: 26, start: "14:00", end: "15:00", price: nil, client: nil, status: .available),
        block(id: "free-2", day: 28, start: "09:00", end: "10:00", price: nil, client: nil, status: .available),
        block(id: "prev-1", monthOffset: -1, day: 5, start: "10:00", end: "11:00", price: 450, client: "client-olena", status: .confirmed),
        block(id: "prev-2", monthOffset: -1, day: 9, start: "10:00", end: "11:00", price: 600, client: "client-maria", status: .confirmed)
    ]

    static let emptyMonth: [Block] = []

    private static func block(
        id: String,
        monthOffset: Int = 0,
        day: Int,
        start: String,
        end: String,
        price: Int?,
        client: String?,
        status: BlockStatus
    ) -> Block {
        Block(
            id: id,
            date: date(monthOffset: monthOffset, day: day),
            startTime: start,
            endTime: end,
            offeredServiceIds: ["svc-classic"],
            bookedServiceId: client == nil ? nil : "svc-classic",
            bookedServiceName: client == nil ? nil : "Класичний манікюр",
            bookedServicePrice: price,
            status: status,
            clientId: client
        )
    }

    private static func date(monthOffset: Int, day: Int) -> String {
        let calendar = DateFormat.salonCalendar
        let start = StatsCalculator.monthStart(containing: reference)
        let month = calendar.date(byAdding: .month, value: monthOffset, to: start) ?? start
        let target = calendar.date(byAdding: .day, value: day - 1, to: month) ?? month

        return DateFormat.date.string(from: target)
    }
}
#endif
