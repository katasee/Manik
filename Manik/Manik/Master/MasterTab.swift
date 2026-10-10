import SwiftUI

enum MasterTab: CaseIterable, Identifiable {
    case schedule
    case clients
    case stats

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .schedule: "calendar"
        case .clients: "person.2"
        case .stats: "slider.horizontal.3"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .schedule: "tabBar.tab.schedule"
        case .clients: "tabBar.tab.clients"
        case .stats: "tabBar.tab.stats"
        }
    }
}
