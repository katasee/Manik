#if DEBUG
import Foundation

enum ClientsPreviewData {
    static let clients: [Client] = [
        Client(id: "client-olya", name: "Оля", instagram: "olya.nails", phone: "+48600123456", createdAt: daysAgo(1)),
        Client(id: "client-kate", name: "Катя", instagram: "kate_m", createdAt: daysAgo(3)),
        Client(id: "client-marina", name: "Марина", phone: "+48511222333", createdAt: daysAgo(8)),
        Client(id: "client-sonya", instagram: "sonya.art", createdAt: daysAgo(12)),
        Client(id: "client-long", name: "Олександра-Вікторія Коваленко-Шевчук", instagram: "oleksandra.viktoria.kovalenko", phone: "+48733444555", createdAt: daysAgo(20)),
        Client(id: "client-legacy", name: "Ірина", phone: "600 12 34", createdAt: daysAgo(35))
    ]

    private static func daysAgo(_ days: Int) -> Date {
        Date(timeIntervalSinceNow: -Double(days) * 86_400)
    }
}
#endif
