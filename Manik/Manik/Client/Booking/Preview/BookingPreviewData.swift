import Foundation

#if DEBUG
enum BookingPreviewData {
    static let reference = Date.now

    static let clientId = "preview-client"

    static let services: [Service] = [
        Service(id: "svc-classic", name: "Класичний манікюр", price: 450, isActive: true),
        Service(id: "svc-gel", name: "Манікюр + гель-лак", price: 750, isActive: true),
        Service(id: "svc-pedicure", name: "Педикюр класичний", price: 600, isActive: true),
        Service(id: "svc-extension", name: "Нарощення", price: 1500, isActive: true)
    ]

    static let blocks: [Block] = [
        block(id: "b1", dayOffset: 1, start: "10:00", end: "11:00", services: ["svc-classic", "svc-gel"]),
        block(id: "b2", dayOffset: 1, start: "11:00", end: "12:00", services: ["svc-classic", "svc-gel"]),
        block(id: "b3", dayOffset: 1, start: "15:00", end: "16:00", services: ["svc-classic", "svc-gel", "svc-pedicure"]),
        block(id: "b4", dayOffset: 4, start: "09:00", end: "10:00", services: ["svc-pedicure"]),
        block(id: "b7", dayOffset: 2, start: "12:00", end: "13:00", services: ["svc-classic", "svc-gel"]),
        block(id: "b8", dayOffset: 6, start: "14:00", end: "15:00", services: ["svc-classic"]),
        block(id: "b9", dayOffset: 9, start: "16:00", end: "17:00", services: ["svc-classic", "svc-pedicure"]),
        block(id: "b6", dayOffset: 40, start: "13:00", end: "14:00", services: ["svc-classic"]),
        block(id: "b5", dayOffset: -2, start: "10:00", end: "11:00", services: ["svc-extension"])
    ]

    private static func block(
        id: String,
        dayOffset: Int,
        start: String,
        end: String,
        services: [String]
    ) -> Block {
        Block(
            id: id,
            date: date(dayOffset),
            startTime: start,
            endTime: end,
            offeredServiceIds: services,
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )
    }

    private static func date(_ dayOffset: Int) -> String {
        let day = Calendar.current.date(
            byAdding: .day,
            value: dayOffset,
            to: reference
        ) ?? reference

        return DateFormat.date.string(from: day)
    }
}
#endif
