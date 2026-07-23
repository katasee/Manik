import SwiftUI

enum ClientTab: CaseIterable, Identifiable {
    case booking
    case myBookings

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .booking: "calendar"
        case .myBookings: "list.bullet.clipboard"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .booking: "tabBar.tab.booking"
        case .myBookings: "tabBar.tab.myBookings"
        }
    }
}
