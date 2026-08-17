import Foundation

#if DEBUG
enum MyBookingsPreviewData {
    static let reference = Date.now

    static let clientId = "preview-client"

    static let services: [Service] = [
        Service(id: "svc-classic", name: "Класичний манікюр", price: 450, isActive: true),
        Service(id: "svc-gel", name: "Манікюр + гель-лак", price: 750, isActive: true),
        Service(id: "svc-pedicure", name: "Педикюр класичний", price: 600, isActive: true)
    ]

    static let blocks: [Block] = [
        block(id: "mine-1", dayOffset: 2, start: "14:00", end: "15:30", service: "svc-classic", status: .confirmed),
        block(id: "mine-2", dayOffset: 6, start: "11:00", end: "12:00", service: "svc-pedicure", status: .pending),
        block(id: "mine-3", dayOffset: -3, start: "14:00", end: "15:30", service: "svc-classic", status: .confirmed),
        block(id: "mine-4", dayOffset: -9, start: "11:00", end: "12:00", service: "svc-gel", status: .pending),
        block(id: "mine-5", dayOffset: -14, start: "16:00", end: "17:00", service: "svc-removed", status: .confirmed),
        block(id: "mine-6", dayOffset: -21, start: "10:00", end: "11:30", service: "svc-classic", status: .confirmed),
        block(id: "mine-7", dayOffset: -28, start: "12:00", end: "13:00", service: "svc-pedicure", status: .confirmed),
        block(id: "mine-8", dayOffset: -35, start: "09:00", end: "10:00", service: "svc-gel", status: .confirmed),
        block(id: "other-1", dayOffset: 3, start: "10:00", end: "11:00", service: "svc-classic", status: .confirmed, clientId: "someone-else"),
        block(id: "free-1", dayOffset: 4, start: "09:00", end: "10:00", service: nil, status: .available, clientId: nil)
    ]

    static let upcomingOnly: [Block] = [
        block(id: "mine-1", dayOffset: 2, start: "14:00", end: "15:30", service: "svc-classic", status: .confirmed)
    ]

    private static func block(
        id: String,
        dayOffset: Int,
        start: String,
        end: String,
        service: String?,
        status: BlockStatus,
        clientId: String? = MyBookingsPreviewData.clientId
    ) -> Block {
        Block(
            id: id,
            date: date(dayOffset),
            startTime: start,
            endTime: end,
            offeredServiceIds: [service].compactMap { $0 },
            bookedServiceId: service,
            status: status,
            clientId: clientId
        )
    }

    private static func date(_ dayOffset: Int) -> String {
        let day = DateFormat.salonCalendar.date(
            byAdding: .day,
            value: dayOffset,
            to: reference
        ) ?? reference

        return DateFormat.date.string(from: day)
    }
}
#endif
