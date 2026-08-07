import SwiftUI

struct MasterRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: MasterTab = .schedule

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .schedule:
                    ScheduleView()
                case .requests:
                    placeholder
                case .stats:
                    StatsView()
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

    private var placeholder: some View {
        VStack(spacing: 16) {
            Text("master.placeholder.title")
                .font(.elmsSans(.bold, 24))
                .foregroundStyle(Color.ink)

            Text(selectedTab.titleKey)
                .font(.elmsSans(.medium, 16))
                .foregroundStyle(Color.textSecondary)

            Text(profile.name)
                .font(.elmsSans(.regular, 16))
                .foregroundStyle(Color.textSecondary)

            Button(action: onSignOut) {
                Text("common.action.signOut")
                    .font(.elmsSans(.bold, 14.5))
            }
        }
    }
}

#Preview {
    MasterRootView(
        profile: UserProfile(uid: "preview", role: .master, name: "Марина", email: "master@example.com"),
        onSignOut: {}
    )
}
