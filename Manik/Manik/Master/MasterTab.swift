import SwiftUI

enum MasterTab: CaseIterable, Identifiable {
    case schedule
    case stats

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .schedule: "calendar"
        case .stats: "slider.horizontal.3"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .schedule: "tabBar.tab.schedule"
        case .stats: "tabBar.tab.stats"
        }
    }
}
