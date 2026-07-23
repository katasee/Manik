import SwiftUI

struct TabBarButton: View {
    let systemImage: String
    let titleKey: LocalizedStringKey
    let isActive: Bool
    let badge: Int?
    let namespace: Namespace.ID
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(
            titleKey,
            systemImage: systemImage,
            action: action
        )
            .labelStyle(.iconOnly)
            .font(.system(size: TabBarMetrics.Size.iconSize, weight: .medium))
            .foregroundStyle(iconColor)
            .frame(width: TabBarMetrics.Size.activeCircleDiameter, height: TabBarMetrics.Size.activeCircleDiameter)
            .background(activeBackground)
            .offset(y: liftOffset)
            .overlay(alignment: .topTrailing) {
                if let badge {
                    TabBarBadge(count: badge)
                        .offset(x: 4, y: -4)
                }
            }
            .animation(TabBarMetrics.AnimationStyle.selection, value: isActive)
            .accessibilityAddTraits(isActive ? [.isSelected] : [])
            .accessibilityValue(badge.map(String.init) ?? "")
    }

    @ViewBuilder
    private var activeBackground: some View {
        if reduceMotion {
            Circle()
                .fill(Color.tabBarActiveBackground)
                .opacity(isActive ? 1 : 0)
        } else if isActive {
            Circle()
                .fill(Color.tabBarActiveBackground)
                .matchedGeometryEffect(id: "activeTabCircle", in: namespace)
        }
    }

    private var iconColor: Color {
        isActive ? Color.textPrimary : Color.tabBarActiveBackground.opacity(TabBarMetrics.Opacity.inactiveIcon)
    }

    private var liftOffset: CGFloat {
        isActive ? -TabBarMetrics.Size.activeCircleLift : 0
    }
}

#Preview {
    @Previewable @Namespace var namespace

    HStack(spacing: TabBarMetrics.Spacing.tabSpacing) {
        TabBarButton(
            systemImage: "calendar",
            titleKey: "tabBar.tab.schedule",
            isActive: false,
            badge: nil,
            namespace: namespace,
            action: {}
        )
        TabBarButton(
            systemImage: "bell",
            titleKey: "tabBar.tab.requests",
            isActive: false,
            badge: 2,
            namespace: namespace,
            action: {}
        )
        TabBarButton(
            systemImage: "slider.horizontal.3",
            titleKey: "tabBar.tab.stats",
            isActive: true,
            badge: nil,
            namespace: namespace,
            action: {}
        )
    }
    .padding(.horizontal, TabBarMetrics.Spacing.innerHorizontalPadding)
    .frame(height: TabBarMetrics.Size.capsuleHeight)
    .background(Color.tabBarBackground, in: .capsule)
    .padding()
}
