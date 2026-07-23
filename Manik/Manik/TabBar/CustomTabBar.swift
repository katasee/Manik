import SwiftUI

struct CustomTabBar: View {
    let kind: CabinetKind

    @Namespace private var tabBarNamespace

    var body: some View {
        Group {
            switch kind {
            case .master(let selection, let badge):
                HStack(spacing: TabBarMetrics.Spacing.tabSpacing) {
                    ForEach(MasterTab.allCases) { tab in
                        TabBarButton(
                            systemImage: tab.systemImage,
                            titleKey: tab.titleKey,
                            isActive: tab == selection.wrappedValue,
                            badge: badge(tab),
                            namespace: tabBarNamespace,
                            action: { selection.wrappedValue = tab }
                        )
                    }
                }
            case .client(let selection):
                HStack(spacing: TabBarMetrics.Spacing.tabSpacing) {
                    ForEach(ClientTab.allCases) { tab in
                        TabBarButton(
                            systemImage: tab.systemImage,
                            titleKey: tab.titleKey,
                            isActive: tab == selection.wrappedValue,
                            badge: nil,
                            namespace: tabBarNamespace,
                            action: { selection.wrappedValue = tab }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, TabBarMetrics.Spacing.innerHorizontalPadding)
        .frame(height: TabBarMetrics.Size.capsuleHeight)
        .background(Color.tabBarBackground, in: .capsule)
        .padding(.horizontal, TabBarMetrics.Spacing.capsuleHorizontalPadding)
        .padding(.bottom, TabBarMetrics.Spacing.bottomInset)
    }
}

#Preview("Master — 3 tabs") {
    @Previewable @State var selection: MasterTab = .schedule

    ZStack(alignment: .bottom) {
        Color.background.ignoresSafeArea()
        CustomTabBar(kind: .master(selection: $selection, badge: { $0 == .requests ? 2 : nil }))
    }
}

#Preview("Client — 2 tabs") {
    @Previewable @State var selection: ClientTab = .booking

    ZStack(alignment: .bottom) {
        Color.background.ignoresSafeArea()
        CustomTabBar(kind: .client(selection: $selection))
    }
}
