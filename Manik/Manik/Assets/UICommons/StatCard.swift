import SwiftUI

struct StatCard: View {
    let iconName: String
    let tint: Color
    let value: String
    var unitKey: LocalizedStringKey?
    let titleKey: LocalizedStringKey
    var valueLineLimit = 1
    var trend: StatsTrend?

    private enum Layout {
        static let contentSpacing: CGFloat = 8
        static let valueSpacing: CGFloat = 4
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 24
        static let value: CGFloat = 26
        static let valueScale: CGFloat = 0.6
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.contentSpacing) {
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
            padding: Layout.padding,
            cornerRadius: Layout.cornerRadius,
            fillsHeight: true
        )
    }

    private var badge: some View {
        IconBadge(systemName: iconName, tint: tint)
    }

    private var valueRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: Layout.valueSpacing) {
            Text(verbatim: value)
                .font(.elmsSans(.bold, Layout.value))
                .foregroundStyle(Color.ink)
                .lineLimit(valueLineLimit)
                .minimumScaleFactor(Layout.valueScale)

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

#Preview {
    Grid(horizontalSpacing: 14, verticalSpacing: 14) {
        GridRow {
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

        GridRow {
            StatCard(
                iconName: "heart",
                tint: Color.freeSlot,
                value: "Манікюр + гель-лак",
                titleKey: "account.stats.favorite",
                valueLineLimit: 2
            )

            StatCard(
                iconName: "clock",
                tint: Color.statusAvailable,
                value: "8,5",
                unitKey: "stats.hours.unit",
                titleKey: "stats.card.hours"
            )
        }
    }
    .padding()
    .background(Color.background)
}
