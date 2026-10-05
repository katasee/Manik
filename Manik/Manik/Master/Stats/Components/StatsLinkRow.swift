import SwiftUI

enum StatsRoute: Hashable {
    case services
}

struct StatsLinkRow: View {
    let titleKey: LocalizedStringKey
    let iconName: String
    let route: StatsRoute

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: StatsMetrics.Spacing.linkSpacing) {
                IconBadge(systemName: iconName)

                Text(titleKey)
                    .font(.elmsSans(.semiBold, 16))
                    .foregroundStyle(Color.ink)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.elmsSans(.semiBold, StatsMetrics.Size.chevron))
                    .foregroundStyle(Color.textSecondary)
            }
            .cardSurface(
                padding: StatsMetrics.Spacing.cardPadding,
                cornerRadius: StatsMetrics.Size.cardCornerRadius
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        StatsLinkRow(
            titleKey: "services.action.open",
            iconName: "list.bullet.rectangle",
            route: .services
        )
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.background)
        .navigationDestination(for: StatsRoute.self) { _ in
            Text(verbatim: "destination")
        }
    }
}
#endif
