import SwiftUI

struct MasterRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: MasterTab = .schedule
    @State private var creatingBlockContext: CreateBlockContext?

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .schedule:
                    #if DEBUG
                    ScheduleView(
                        serviceRepository: FakeServiceRepository(services: SchedulePreviewData.services),
                        onCreateSlotRequested: { context in
                            withAnimation(.easeOut(duration: 0.2)) {
                                creatingBlockContext = context
                            }
                        }
                    )
                    #else
                    ScheduleView(onCreateSlotRequested: { context in
                        withAnimation(.easeOut(duration: 0.2)) {
                            creatingBlockContext = context
                        }
                    })
                    #endif
                case .requests, .stats:
                    placeholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: TabBarMetrics.Size.reservedClearance)
            }

            CustomTabBar(kind: .master(selection: $selectedTab, badge: { _ in nil }))

            if let context = creatingBlockContext {
                AddNewSlotBlock(
                    date: context.date,
                    startHour: context.startHour,
                    services: context.services,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            creatingBlockContext = nil
                        }
                    }
                )
                .zIndex(1)
            }
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
