import SwiftUI

struct StatsTrendLabel: View {
    let trend: StatsTrend

    private var color: Color {
        trend.direction == .up ? Color.freeSlot : Color.destructive
    }

    var body: some View {
        HStack(spacing: StatsMetrics.Spacing.trendSpacing) {
            Image(systemName: trend.direction == .up ? "arrow.up" : "arrow.down")
                .font(.elmsSans(.bold, 11))

            Text(verbatim: trend.valueLabel)
                .font(.elmsSans(.bold, 13))

            Text("stats.trend.previousMonth")
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.textSecondary)
        }
        .foregroundStyle(color)
        .lineLimit(2)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 12) {
        StatsTrendLabel(trend: StatsTrend(direction: .up, valueLabel: "18%"))
        StatsTrendLabel(trend: StatsTrend(direction: .down, valueLabel: "2"))
    }
    .padding()
    .background(Color.background)
}
#endif
