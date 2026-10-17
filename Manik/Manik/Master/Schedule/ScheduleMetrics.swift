import CoreGraphics

enum ScheduleMetrics {
    enum Size {
        static let rowHeight: CGFloat = 52
        static let rowCornerRadius: CGFloat = 18
        static let rowBorderWidth: CGFloat = 1.5
        static let rowDash: [CGFloat] = [5, 4]
        static let rowTime: CGFloat = 16
        static let rowLabel: CGFloat = 13
        static let rowLabelTracking: CGFloat = 0.8
        static let pastOpacity: Double = 0.45
        static let fillTitle: CGFloat = 18
        static let weekdayLetter: CGFloat = 12
        static let dayCellHeight: CGFloat = 44
        static let daySelection: CGFloat = 34
        static let dayNumber: CGFloat = 15
        static let dayDot: CGFloat = 4
        static let chipHeight: CGFloat = 44
        static let chipTime: CGFloat = 15
        static let chipGlyph: CGFloat = 10
        static let chipTextScale: CGFloat = 0.75
        static let monthTitle: CGFloat = 17
        static let monthChevron: CGFloat = 12
        static let monthRowHeight: CGFloat = 44
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let stripVerticalPadding: CGFloat = 12
        static let listTopPadding: CGFloat = 8
        static let rowSpacing: CGFloat = 10
        static let rowHorizontalPadding: CGFloat = 18
        static let contentBottomPadding: CGFloat = 24
        static let calendarColumnSpacing: CGFloat = 2
        static let calendarRowSpacing: CGFloat = 2
        static let dayDotSpacing: CGFloat = 2
        static let chipSpacing: CGFloat = 8
        static let chipGlyphSpacing: CGFloat = 4
        static let hoursSpacing: CGFloat = 12
        static let scrollShadowInset: CGFloat = 8
        static let monthChevronSpacing: CGFloat = 6
    }
}
