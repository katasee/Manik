import SwiftUI

struct StatsTrend {
    enum Direction {
        case up
        case down
    }

    let direction: Direction
    let valueLabel: String

    static func percent(current: Int, previous: Int) -> StatsTrend? {
        guard previous > 0, current != previous else { return nil }

        let ratio = abs(Double(current - previous)) / Double(previous)

        return StatsTrend(
            direction: current > previous ? .up : .down,
            valueLabel: ratio.formatted(.percent.precision(.fractionLength(0)))
        )
    }

    static func count(current: Int, previous: Int) -> StatsTrend? {
        guard current != previous else { return nil }

        return StatsTrend(
            direction: current > previous ? .up : .down,
            valueLabel: abs(current - previous).formatted()
        )
    }
}

struct StatsTrendLabel: View {
    let trend: StatsTrend

    private enum Layout {
        static let spacing: CGFloat = 4
    }

    private var color: Color {
        trend.direction == .up ? Color.freeSlot : Color.destructive
    }

    var body: some View {
        HStack(spacing: Layout.spacing) {
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

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        StatsTrendLabel(trend: StatsTrend(direction: .up, valueLabel: "18%"))
        StatsTrendLabel(trend: StatsTrend(direction: .down, valueLabel: "2"))
    }
    .padding()
    .background(Color.background)
}
