import SwiftUI

struct MasterRootView: View {
    let onSignOut: () -> Void

    @State private var selectedTab: MasterTab = .schedule
    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var requestsViewModel = RequestsViewModel()
    @State private var statsViewModel = StatsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .schedule:
                    ScheduleView(viewModel: scheduleViewModel)
                case .requests:
                    RequestsView(viewModel: requestsViewModel)
                case .stats:
                    StatsView(
                        viewModel: statsViewModel,
                        onSignOut: onSignOut,
                        bottomClearance: TabBarMetrics.Size.reservedClearance
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: TabBarMetrics.Size.reservedClearance)
            }

            CustomTabBar(kind: .master(selection: $selectedTab, badge: { _ in nil }))
        }
    }
}

#Preview {
    MasterRootView(onSignOut: {})
}
