import SwiftUI

struct WeekDayStrip: View {
    @Binding var selectedDate: Date

    @Namespace private var namespace

    private enum Layout {
        static let daySpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 6
        static let chevronWidth: CGFloat = 32
        static let chevronHeight: CGFloat = 44
        static let selectionAnimation = Animation.spring(response: 0.35, dampingFraction: 0.75)
    }

    private var weekDates: [Date] {
        Self.weekDates(containing: selectedDate)
    }

    var body: some View {
        HStack(spacing: Layout.daySpacing) {
            weekNavButton(forward: false)

            ForEach(weekDates, id: \.self) { day in
                WeekDayCell(
                    day: day,
                    isSelected: DateFormat.salonCalendar.isDate(day, inSameDayAs: selectedDate),
                    isToday: DateFormat.salonCalendar.isDateInToday(day),
                    namespace: namespace,
                    action: { select(day) }
                )
            }

            weekNavButton(forward: true)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .gesture(weekSwipeGesture)
    }

    private var weekSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                shiftWeek(forward: value.translation.width < 0)
            }
    }

    private func select(_ day: Date) {
        withAnimation(Layout.selectionAnimation) {
            selectedDate = day
        }
    }

    private func shiftWeek(forward: Bool) {
        let calendar = DateFormat.salonCalendar

        guard
            let shifted = calendar.date(
                byAdding: .weekOfYear,
                value: forward ? 1 : -1,
                to: selectedDate
            ),
            let week = calendar.dateInterval(of: .weekOfYear, for: shifted)
        else {
            return
        }

        let now = Date.now
        let isCurrentWeek = calendar.isDate(
            now,
            equalTo: shifted,
            toGranularity: .weekOfYear
        )

        select(isCurrentWeek ? now : week.start)
    }

    private func weekNavButton(forward: Bool) -> some View {
        Button {
            shiftWeek(forward: forward)
        } label: {
            Image(systemName: forward ? "chevron.right" : "chevron.left")
                .font(.elmsSans(.semiBold, 13))
                .foregroundStyle(Color.textSecondary)
                .frame(width: Layout.chevronWidth, height: Layout.chevronHeight)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private static func weekDates(containing date: Date) -> [Date] {
        let startOfWeek = DateFormat.salonCalendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { DateFormat.salonCalendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date.now

    WeekDayStrip(selectedDate: $selectedDate)
        .padding(.vertical, 24)
        .background(Color.background)
}
