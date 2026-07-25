import SwiftUI

enum ClientTab: CaseIterable, Identifiable {
    case booking
    case myBookings
    case account

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .booking: "calendar"
        case .myBookings: "list.bullet.clipboard"
        case .account: "person.crop.circle"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .booking: "tabBar.tab.booking"
        case .myBookings: "tabBar.tab.myBookings"
        case .account: "tabBar.tab.account"
        }
    }
}
