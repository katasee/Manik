import SwiftUI

struct MonthGrid: View {
    let month: BookingMonth
    let selectedDate: String?
    let onSelect: (BookingDay) -> Void

    private static let columns = Array(
        repeating: GridItem(.flexible(), spacing: BookingMetrics.Spacing.gridSpacing),
        count: BookingAvailability.daysPerWeek
    )

    var body: some View {
        VStack(spacing: BookingMetrics.Spacing.weekdayRowSpacing) {
            weekdayRow
            grid
        }
    }

    private var weekdayRow: some View {
        LazyVGrid(columns: Self.columns, spacing: 0) {
            ForEach(month.weekdaySymbols.indices, id: \.self) { index in
                Text(verbatim: month.weekdaySymbols[index])
                    .font(.elmsSans(.medium, 11))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Self.columns,
            alignment: .center,
            spacing: BookingMetrics.Spacing.gridSpacing
        ) {
            ForEach(month.days) { day in
                CalendarDayCell(
                    day: day,
                    isSelected: day.date == selectedDate,
                    onTap: { onSelect(day) }
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selected: String?

    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )
    let month = BookingAvailability.month(
        startingAt: BookingPreviewData.reference,
        for: offers[0],
        now: BookingPreviewData.reference
    )

    return MonthGrid(
        month: month,
        selectedDate: selected,
        onSelect: { selected = $0.date }
    )
    .padding()
    .background(Color.background)
}
#endif
