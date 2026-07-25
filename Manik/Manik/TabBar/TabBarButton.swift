import SwiftUI

struct TabBarButton: View {
    let systemImage: String
    let titleKey: LocalizedStringKey
    let isActive: Bool
    let badge: Int?
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                image
                    .overlay(alignment: .topTrailing) {
                        if let badge {
                            TabBarBadge(count: badge)
                                .offset(x: TabBarMetrics.Offset.badgeX, y: TabBarMetrics.Offset.badgeY)
                        }
                    }
                
                title
            }
        }
        .offset(y: liftOffset)
        .animation(TabBarMetrics.AnimationStyle.selection, value: isActive)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var image: some View {
        Image(systemName: systemImage)
            .font(.system(size: TabBarMetrics.Size.iconSize, weight: .medium))
            .foregroundStyle(iconColor)
            .frame(
                width: isActive ? TabBarMetrics.Size.activeCircleDiameter : TabBarMetrics.Size.iconSize,
                height: isActive ? TabBarMetrics.Size.activeCircleDiameter : TabBarMetrics.Size.iconSize
            )
            .background(
                TabBarActiveIndicator(isActive: isActive, namespace: namespace)
            )
    }
    
    private var title: some View {
        Text(titleKey)
            .font(.elmsSans(.medium, TabBarMetrics.Size.captionFontSize))
            .foregroundStyle(captionColor)
    }
    
    private var iconColor: Color {
        isActive ? Color.ink : Color.background.opacity(TabBarMetrics.Opacity.inactiveIcon)
    }
    
    private var captionColor: Color {
        isActive ? Color.background : Color.background.opacity(TabBarMetrics.Opacity.inactiveIcon)
    }
    
    private var liftOffset: Double {
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
    .background(Color.ink, in: .capsule)
    .padding()
}

