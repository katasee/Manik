import SwiftUI

struct StatCard: View {
    let iconName: String
    let tint: Color
    let value: String
    var unitKey: LocalizedStringKey?
    let titleKey: LocalizedStringKey
    var trend: StatsTrend?

    var body: some View {
        VStack(alignment: .leading, spacing: StatsMetrics.Spacing.cardContentSpacing) {
            badge

            valueRow

            Text(titleKey)
                .font(.elmsSans(.medium, 14))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)

            trendRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(
            padding: StatsMetrics.Spacing.cardPadding,
            cornerRadius: StatsMetrics.Size.cardCornerRadius,
            fillsHeight: true
        )
    }

    private var badge: some View {
        IconBadge(systemName: iconName, tint: tint)
    }

    private var valueRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: StatsMetrics.Spacing.trendSpacing) {
            Text(verbatim: value)
                .font(.elmsSans(.bold, StatsMetrics.Size.statValue))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            unitText
        }
    }

    @ViewBuilder
    private var unitText: some View {
        if let unitKey {
            Text(unitKey)
                .font(.elmsSans(.medium, 14))
                .foregroundStyle(Color.textSecondary)
        }
    }

    @ViewBuilder
    private var trendRow: some View {
        if let trend {
            StatsTrendLabel(trend: trend)
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 14) {
        StatCard(
            iconName: "checkmark.circle",
            tint: Color.statusConfirmed,
            value: "12",
            titleKey: "stats.card.visits"
        )

        StatCard(
            iconName: "person.2",
            tint: Color.statusPending,
            value: "9",
            titleKey: "stats.card.clients",
            trend: StatsTrend(direction: .up, valueLabel: "2")
        )
    }
    .padding()
    .background(Color.background)
}
#endif
