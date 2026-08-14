import SwiftUI

struct CalendarDayCell: View {
    let day: BookingDay
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: BookingMetrics.Spacing.footerSpacing) {
                dayNumber
                underline
            }
            .frame(maxWidth: .infinity, minHeight: BookingMetrics.Size.dayCell)
            .opacity(day.isInMonth ? 1 : BookingMetrics.Opacity.outsideMonth)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(day.isSelectable == false)
    }

    private var dayNumber: some View {
        Text(verbatim: day.numberLabel)
            .font(.elmsSans(.medium, 15))
            .foregroundStyle(numberColor)
            .frame(
                width: BookingMetrics.Size.daySelection,
                height: BookingMetrics.Size.daySelection
            )
            .background(isSelected ? Color.ink : Color.clear, in: .circle)
    }

    private var underline: some View {
        Capsule()
            .fill(showsUnderline ? Color.freeSlot : Color.clear)
            .frame(
                width: BookingMetrics.Size.dayUnderlineWidth,
                height: BookingMetrics.Size.dayUnderlineHeight
            )
    }

    private var showsUnderline: Bool {
        day.isAvailable && isSelected == false
    }

    private var numberColor: Color {
        if isSelected { return Color.background }

        return day.isSelectable ? Color.ink : Color.textSecondary
    }
}

#if DEBUG
#Preview {
    let days = [
        BookingDay(date: "2026-08-10", numberLabel: "10", isInMonth: true, isAvailable: true, isPast: false),
        BookingDay(date: "2026-08-11", numberLabel: "11", isInMonth: true, isAvailable: false, isPast: false),
        BookingDay(date: "2026-08-12", numberLabel: "12", isInMonth: true, isAvailable: true, isPast: false),
        BookingDay(date: "2026-08-01", numberLabel: "1", isInMonth: true, isAvailable: false, isPast: true),
        BookingDay(date: "2026-09-01", numberLabel: "1", isInMonth: false, isAvailable: true, isPast: false)
    ]

    return HStack(spacing: BookingMetrics.Spacing.gridSpacing) {
        ForEach(days) { day in
            CalendarDayCell(
                day: day,
                isSelected: day.date == "2026-08-12",
                onTap: {}
            )
        }
    }
    .padding()
    .background(Color.background)
}
#endif
