import SwiftUI

struct MasterRootView: View {
    let onSignOut: () -> Void

    @State private var selectedTab: MasterTab = .schedule
    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var requestsViewModel = RequestsViewModel()
    @State private var statsViewModel = StatsViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MasterTab.allCases) { tab in
                Tab(
                    tab.titleKey,
                    systemImage: tab.systemImage,
                    value: tab
                ) {
                    Group {
                        switch tab {
                        case .schedule:
                            ScheduleView(viewModel: scheduleViewModel)
                        case .requests:
                            RequestsView(viewModel: requestsViewModel)
                        case .stats:
                            StatsView(viewModel: statsViewModel, onSignOut: onSignOut)
                        }
                    }
                    .tint(Color.accentColor)
                }
                .badge(tab == .requests ? requestsViewModel.requests.count : 0)
            }
        }
        .tint(Color.ink)
        .task {
            await requestsViewModel.observeBlocks()
        }
        .task {
            await requestsViewModel.refreshRequests()
        }
    }
}

#Preview {
    MasterRootView(onSignOut: {})
}
