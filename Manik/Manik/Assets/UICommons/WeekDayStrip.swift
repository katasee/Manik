import SwiftUI

struct WeekDayStrip: View {
    @Binding var selectedDate: Date
    @Namespace private var namespace

    private enum Layout {
        static let daySpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 6
        static let cellSize: CGFloat = 40
        static let chevronSize: CGFloat = 32
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
        guard let newDate = Self.calendar.date(byAdding: .day, value: forward ? 7 : -7, to: selectedDate) else {
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
        let isSelected = Self.calendar.isDate(day, inSameDayAs: selectedDate)
        let isToday = Self.calendar.isDateInToday(day)

        return Button {
            withAnimation(Layout.selectionAnimation) {
                selectedDate = day
            }
        } label: {
            VStack(spacing: 2) {
                Text(DateFormat.weekdayLetter.string(from: day).uppercased())
                    .font(.elmsSans(.medium, 11))

                Text(DateFormat.dayNumber.string(from: day))
                    .font(.elmsSans(.bold, 15))
            }
            .foregroundStyle(isSelected ? .white : Color.textSecondary)
            .frame(width: Layout.cellSize, height: Layout.cellSize)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.ink)
                        .brandShadow()
                        .matchedGeometryEffect(id: "selectedDay", in: namespace)
                } else if isToday {
                    Capsule()
                        .strokeBorder(Color.surface, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DateFormat.salonTimeZone
        calendar.firstWeekday = 2
        return calendar
    }()

    private static func weekDates(containing date: Date) -> [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()

    WeekDayStrip(selectedDate: $selectedDate)
        .padding(.vertical, 24)
        .background(Color.background)
}
