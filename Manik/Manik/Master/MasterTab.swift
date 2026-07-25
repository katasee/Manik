import SwiftUI

enum MasterTab: CaseIterable, Identifiable {
    case schedule
    case requests
    case stats

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .schedule: "calendar"
        case .requests: "bell"
        case .stats: "slider.horizontal.3"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .schedule: "tabBar.tab.schedule"
        case .requests: "tabBar.tab.requests"
        case .stats: "tabBar.tab.stats"
        }
    }
}
