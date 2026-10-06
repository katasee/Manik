import SwiftUI

struct WeekDayStrip: View {
    @Binding var selectedDate: Date
    @Namespace private var namespace

    private enum Layout {
        static let daySpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 6
        static let cellHeight: CGFloat = 58
        static let cellCornerRadius: CGFloat = 18
        static let labelSpacing: CGFloat = 4
        static let chevronSize: CGFloat = 32
        static let todayOutline: CGFloat = 1
        static let selectedLetterOpacity: Double = 0.7
        static let selectionAnimation = Animation.spring(response: 0.35, dampingFraction: 0.75)
    }

    private var weekDates: [Date] {
        Self.weekDates(containing: selectedDate)
    }

    var body: some View {
        HStack(spacing: Layout.daySpacing) {
            weekNavButton(forward: false)

            ForEach(weekDates, id: \.self) { day in
                dayCell(day)
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

    private func shiftWeek(forward: Bool) {
        guard let newDate = DateFormat.salonCalendar.date(byAdding: .day, value: forward ? 7 : -7, to: selectedDate) else {
            return
        }
        withAnimation(Layout.selectionAnimation) {
            selectedDate = newDate
        }
    }

    private func weekNavButton(forward: Bool) -> some View {
        Button {
            shiftWeek(forward: forward)
        } label: {
            Image(systemName: forward ? "chevron.right" : "chevron.left")
                .font(.elmsSans(.semiBold, 13))
                .foregroundStyle(Color.textSecondary)
                .frame(width: Layout.chevronSize, height: Layout.chevronSize)
        }
        .buttonStyle(.plain)
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = DateFormat.salonCalendar.isDate(day, inSameDayAs: selectedDate)
        let isToday = DateFormat.salonCalendar.isDateInToday(day)

        return Button {
            withAnimation(Layout.selectionAnimation) {
                selectedDate = day
            }
        } label: {
            VStack(spacing: Layout.labelSpacing) {
                Text(DateFormat.weekdayLetter.string(from: day).uppercased())
                    .font(.elmsSans(.medium, 11))
                    .foregroundStyle(
                        isSelected
                            ? Color.white.opacity(Layout.selectedLetterOpacity)
                            : Color.textSecondary
                    )

                Text(DateFormat.dayNumber.string(from: day))
                    .font(.elmsSans(.semiBold, 16))
                    .foregroundStyle(dayNumberColor(isSelected: isSelected, isToday: isToday))
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.cellHeight)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: Layout.cellCornerRadius)
                        .fill(Color.ink)
                        .brandShadow()
                        .matchedGeometryEffect(id: "selectedDay", in: namespace)
                } else if isToday {
                    RoundedRectangle(cornerRadius: Layout.cellCornerRadius)
                        .strokeBorder(Color.stroke, lineWidth: Layout.todayOutline)
                }
            }
            .contentShape(.rect(cornerRadius: Layout.cellCornerRadius))
        }
        .buttonStyle(.plain)
    }

    private func dayNumberColor(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected {
            return Color.white
        }
        return isToday ? Color.wine : Color.ink
    }

    private static func weekDates(containing date: Date) -> [Date] {
        let startOfWeek = DateFormat.salonCalendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { DateFormat.salonCalendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()

    WeekDayStrip(selectedDate: $selectedDate)
        .padding(.vertical, 24)
        .background(Color.background)
}
