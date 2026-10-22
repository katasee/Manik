import SwiftUI

struct WeekDayCell: View {
    let day: Date
    let isSelected: Bool
    let isToday: Bool
    let isEnabled: Bool
    let isMarked: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    private enum Layout {
        static let cellHeight: CGFloat = 58
        static let cellCornerRadius: CGFloat = 18
        static let labelSpacing: CGFloat = 4
        static let dotSize: CGFloat = 4
        static let dotBottomPadding: CGFloat = 6
        static let todayOutline: CGFloat = 1
        static let selectedLetterOpacity: Double = 0.7
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Layout.labelSpacing) {
                Text(DateFormat.weekdayLetter.string(from: day).uppercased())
                    .font(.elmsSans(.medium, 11))
                    .foregroundStyle(
                        isSelected
                            ? Color.onPrimary.opacity(Layout.selectedLetterOpacity)
                            : Color.textSecondary
                    )

                Text(DateFormat.dayNumber.string(from: day))
                    .font(.elmsSans(.semiBold, 16))
                    .foregroundStyle(numberColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.cellHeight)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: Layout.cellCornerRadius)
                        .fill(Color.primaryFill)
                        .brandShadow()
                        .matchedGeometryEffect(id: "selectedDay", in: namespace)
                } else if isToday {
                    RoundedRectangle(cornerRadius: Layout.cellCornerRadius)
                        .strokeBorder(Color.stroke, lineWidth: Layout.todayOutline)
                }
            }
            .overlay(alignment: .bottom) {
                if isMarked {
                    Circle()
                        .fill(isSelected ? Color.onPrimary : Color.wine)
                        .frame(width: Layout.dotSize, height: Layout.dotSize)
                        .padding(.bottom, Layout.dotBottomPadding)
                }
            }
            .contentShape(.rect(cornerRadius: Layout.cellCornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
    }

    private var numberColor: Color {
        if isSelected {
            Color.onPrimary
        } else if isEnabled == false {
            Color.textTertiary
        } else if isToday {
            Color.wine
        } else {
            Color.ink
        }
    }
}

struct WeekDayStrip: View {
    @Binding var selectedDate: Date
    var markedDays: Set<String> = []
    var firstDay = Date.distantPast

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

    private var firstSelectableDay: Date {
        DateFormat.salonCalendar.startOfDay(for: firstDay)
    }

    private var canGoBack: Bool {
        guard let weekStart = weekDates.first else { return true }

        return weekStart > firstSelectableDay
    }

    var body: some View {
        HStack(spacing: Layout.daySpacing) {
            weekNavButton(forward: false)

            ForEach(weekDates, id: \.self) { day in
                WeekDayCell(
                    day: day,
                    isSelected: DateFormat.salonCalendar.isDate(day, inSameDayAs: selectedDate),
                    isToday: DateFormat.salonCalendar.isDateInToday(day),
                    isEnabled: day >= firstSelectableDay,
                    isMarked: markedDays.contains(DateFormat.date.string(from: day)),
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
            forward || canGoBack,
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

        select(max(isCurrentWeek ? now : week.start, firstSelectableDay))
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
        .disabled(forward == false && canGoBack == false)
    }

    private static func weekDates(containing date: Date) -> [Date] {
        let startOfWeek = DateFormat.salonCalendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { DateFormat.salonCalendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date.now

    let inTwoDays = DateFormat.salonCalendar.date(byAdding: .day, value: 2, to: .now) ?? .now

    WeekDayStrip(
        selectedDate: $selectedDate,
        markedDays: [
            DateFormat.date.string(from: .now),
            DateFormat.date.string(from: inTwoDays)
        ],
        firstDay: .now
    )
    .padding(.vertical, 24)
    .background(Color.background)
}
