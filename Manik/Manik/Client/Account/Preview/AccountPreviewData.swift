import Foundation

#if DEBUG
enum AccountPreviewData {
    static let uid = "client-preview"

    static let password = "123456"

    static let reference = Date.now

    static let profile = UserProfile(
        uid: uid,
        role: .client,
        name: "Олена Ковальчук",
        email: "olena@example.com",
        phone: "+48600123456",
        instagram: "olena_nails",
        telegram: "olena"
    )

    static let emptyContactsProfile = UserProfile(
        uid: uid,
        role: .client,
        name: profile.name,
        email: profile.email
    )

    static let services: [Service] = [
        Service(id: "svc-classic", name: "Класичний манікюр", price: 450, isActive: true),
        Service(id: "svc-gel", name: "Манікюр + гель-лак", price: 750, isActive: true),
        Service(id: "svc-pedicure", name: "Педикюр класичний", price: 600, isActive: true)
    ]

    static let blocks: [Block] = [
        block(id: "visit-1", dayOffset: -3, start: "14:00", end: "15:30", service: "svc-gel", status: .confirmed),
        block(id: "visit-2", dayOffset: -17, start: "11:00", end: "12:00", service: "svc-gel", status: .confirmed),
        block(id: "visit-3", dayOffset: -31, start: "16:00", end: "17:00", service: "svc-gel", status: .confirmed),
        block(id: "visit-4", dayOffset: -45, start: "10:00", end: "11:30", service: "svc-classic", status: .confirmed),
        block(id: "visit-5", dayOffset: -59, start: "12:00", end: "13:00", service: "svc-classic", status: .confirmed),
        block(id: "visit-6", dayOffset: -73, start: "09:00", end: "10:00", service: "svc-pedicure", status: .confirmed),
        block(id: "visit-legacy", dayOffset: -87, start: "13:00", end: "14:00", service: nil, status: .confirmed),
        block(id: "upcoming", dayOffset: 4, start: "14:00", end: "15:30", service: "svc-classic", status: .confirmed),
        block(id: "upcoming-2", dayOffset: 9, start: "10:00", end: "11:00", service: "svc-gel", status: .pending),
        block(id: "declined-past", dayOffset: -6, start: "11:00", end: "12:00", service: "svc-pedicure", status: .pending),
        block(id: "other-client", dayOffset: -9, start: "10:00", end: "11:00", service: "svc-gel", status: .confirmed, clientId: "someone-else"),
        block(id: "free", dayOffset: 5, start: "09:00", end: "10:00", service: nil, status: .available, clientId: nil)
    ]

    static let profiles = [uid: profile]

    private static func block(
        id: String,
        dayOffset: Int,
        start: String,
        end: String,
        service: String?,
        status: BlockStatus,
        clientId: String? = AccountPreviewData.uid
    ) -> Block {
        let booked = services.first { $0.id == service }

        return Block(
            id: id,
            date: date(dayOffset),
            startTime: start,
            endTime: end,
            offeredServiceIds: [service].compactMap { $0 },
            bookedServiceId: service,
            bookedServiceName: booked?.name,
            bookedServicePrice: booked?.price,
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
