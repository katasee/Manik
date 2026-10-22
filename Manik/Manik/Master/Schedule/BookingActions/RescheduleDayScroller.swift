import SwiftUI

private struct RescheduleLens: View {
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ScheduleMetrics.Size.dayLensCornerRadius)
    }

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(.regular, in: shape)
            } else {
                shape
                    .fill(Color.raised)
                    .strokeBorder(Color.hairline)
            }
        }
        .frame(
            width: ScheduleMetrics.Size.dayScrollerCell * ScheduleMetrics.Size.dayScrollerSelectedScale,
            height: ScheduleMetrics.Size.dayLensHeight
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct RescheduleDayScroller: View {
    @Binding var selectedDate: Date
    let days: [Date]
    let markedDays: Set<String>

    @State private var scrolledDay: Date?
    @State private var width: CGFloat = 0

    init(
        selectedDate: Binding<Date>,
        days: [Date],
        markedDays: Set<String>
    ) {
        _selectedDate = selectedDate
        self.days = days
        self.markedDays = markedDays
        _scrolledDay = State(initialValue: selectedDate.wrappedValue)
    }

    private var sideMargin: CGFloat {
        max(0, (width - ScheduleMetrics.Size.dayScrollerCell) / 2)
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: ScheduleMetrics.Spacing.dayScrollerSpacing) {
                ForEach(days, id: \.self) { day in
                    WeekDayCell(
                        day: day,
                        isSelected: DateFormat.salonCalendar.isDate(day, inSameDayAs: selectedDate),
                        isToday: DateFormat.salonCalendar.isDateInToday(day),
                        isMarked: markedDays.contains(DateFormat.date.string(from: day)),
                        fillsSelection: false,
                        action: { scroll(to: day) }
                    )
                    .frame(width: ScheduleMetrics.Size.dayScrollerCell)
                    .visualEffect { content, proxy in
                        content.scaleEffect(Self.magnification(of: proxy))
                    }
                }
            }
            .padding(.vertical, ScheduleMetrics.Spacing.dayScrollerVerticalInset)
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, sideMargin, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledDay, anchor: .center)
        .fixedSize(horizontal: false, vertical: true)
        .background {
            RescheduleLens()
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            width = newWidth
        }
        .onChange(of: scrolledDay, selectCentered)
    }

    private nonisolated static func magnification(of proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .scrollView(axis: .horizontal))
        let visibleWidth = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? 0
        let distance = abs(frame.midX - visibleWidth / 2)
        let reach = ScheduleMetrics.Size.dayScrollerCell + ScheduleMetrics.Spacing.dayScrollerSpacing
        let closeness = max(0, 1 - distance / reach)

        return 1 + (ScheduleMetrics.Size.dayScrollerSelectedScale - 1) * closeness
    }

    private func selectCentered() {
        guard let scrolledDay else { return }

        selectedDate = scrolledDay
    }

    private func scroll(to day: Date) {
        withAnimation {
            scrolledDay = day
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selectedDate = DateFormat.salonCalendar.startOfDay(for: .now)

    let today = DateFormat.salonCalendar.startOfDay(for: .now)
    let days = (0..<21).compactMap {
        DateFormat.salonCalendar.date(byAdding: .day, value: $0, to: today)
    }

    RescheduleDayScroller(
        selectedDate: $selectedDate,
        days: days,
        markedDays: [DateFormat.date.string(from: .now)]
    )
    .padding(.vertical, 24)
    .background(Color.background)
}
#endif
