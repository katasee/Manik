import Foundation

#if DEBUG
enum RequestsPreviewData {
    static let reference = Date.now

    static let services: [Service] = [
        Service(id: "svc-classic", name: "Класичний манікюр", price: 450, isActive: true),
        Service(id: "svc-gel", name: "Манікюр + гель-лак", price: 750, isActive: true),
        Service(id: "svc-pedicure", name: "Педикюр класичний", price: 600, isActive: true)
    ]

    static let profiles: [String: UserProfile] = [
        "client-olena": profile(uid: "client-olena", name: "Олена Ковальчук"),
        "client-maria": profile(uid: "client-maria", name: "Марія Ткаченко"),
        "client-sofia": profile(uid: "client-sofia", name: "Софія Бондар")
    ]

    static let blocks: [Block] = [
        block(id: "req-1", dayOffset: 1, start: "10:00", end: "11:00", service: "svc-classic", client: "client-olena"),
        block(id: "req-2", dayOffset: 2, start: "14:00", end: "15:30", service: "svc-gel", client: "client-maria"),
        block(id: "req-3", dayOffset: 4, start: "16:00", end: "17:00", service: "svc-removed", client: "client-sofia"),
        block(id: "req-stale", dayOffset: -2, start: "11:00", end: "12:00", service: "svc-classic", client: "client-olena"),
        block(id: "confirmed-1", dayOffset: 3, start: "09:00", end: "10:00", service: "svc-classic", client: "client-olena", status: .confirmed),
        block(id: "free-1", dayOffset: 3, start: "12:00", end: "13:00", service: nil, client: nil, status: .available)
    ]

    static let unreadableClient: [Block] = [
        block(id: "req-ghost", dayOffset: 1, start: "10:00", end: "11:00", service: "svc-classic", client: "client-deleted")
    ]

    private static func profile(uid: String, name: String) -> UserProfile {
        UserProfile(uid: uid, role: .client, name: name, email: "\(uid)@example.com")
    }

    private static func block(
        id: String,
        dayOffset: Int,
        start: String,
        end: String,
        service: String?,
        client: String?,
        status: BlockStatus = .pending
    ) -> Block {
        Block(
            id: id,
            date: date(dayOffset),
            startTime: start,
            endTime: end,
            offeredServiceIds: [service].compactMap { $0 },
            bookedServiceId: service,
            status: status,
            clientId: client
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
