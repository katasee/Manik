import Foundation

struct CreateBlockContext: Identifiable {
    let id = UUID()
    let date: Date
    let startHour: Int
    let services: [Service]
}
