import SwiftUI

struct FillMonthDayCell: View {
    let day: FillMonthDay
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: ScheduleMetrics.Spacing.dayDotSpacing) {
                Text(verbatim: day.numberText)
                    .font(.elmsSans(.medium, ScheduleMetrics.Size.dayNumber))
                    .foregroundStyle(numberColor)
                    .frame(width: ScheduleMetrics.Size.daySelection, height: ScheduleMetrics.Size.daySelection)
                    .background {
                        if day.isSelected {
                            Circle()
                                .fill(Color.primaryFill)
                                .brandShadow()
                        }
                    }

                Circle()
                    .fill(day.hasSlots ? Color.wine : Color.clear)
                    .frame(width: ScheduleMetrics.Size.dayDot, height: ScheduleMetrics.Size.dayDot)
            }
            .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.dayCellHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(day.isPast)
        .accessibilityAddTraits(day.isSelected ? .isSelected : [])
        .accessibilityValue(day.hasSlots ? Text("schedule.fill.day.hasSlots") : Text(verbatim: ""))
    }

    private var numberColor: Color {
        if day.isSelected { return Color.onPrimary }

        return day.isPast ? Color.textTertiary : Color.ink
    }
}

#if DEBUG
#Preview {
    HStack {
        ForEach(SchedulePreviewData.dayStates) { day in
            FillMonthDayCell(day: day, action: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
