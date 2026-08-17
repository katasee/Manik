import CoreGraphics

enum BookingMetrics {
    enum Size {
        static let cardCornerRadius: CGFloat = 24
        static let headerCornerRadius: CGFloat = 28
        static let pillDot: CGFloat = 8
        static let headerBubble: CGFloat = 180
        static let chevron: CGFloat = 15
        static let chevronButton: CGFloat = 44
        static let successIcon: CGFloat = 44
        static let chipCornerRadius: CGFloat = 14
        static let chipHeight: CGFloat = 44
        static let chipMinWidth: CGFloat = 72
        static let chipBorderWidth: CGFloat = 1
        static let dayCell: CGFloat = 44
        static let daySelection: CGFloat = 34
        static let dayUnderlineWidth: CGFloat = 20
        static let dayUnderlineHeight: CGFloat = 4
        static let monthArrow: CGFloat = 44
        static let monthArrowCircle: CGFloat = 32
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let headerPadding: CGFloat = 20
        static let headerHorizontalPadding: CGFloat = 32
        static let headerContentSpacing: CGFloat = 10
        static let cardPadding: CGFloat = 16
        static let cardContentSpacing: CGFloat = 12
        static let listSpacing: CGFloat = 14
        static let listTopPadding: CGFloat = 12
        static let sectionTopPadding: CGFloat = 20
        static let pillPadding: CGFloat = 12
        static let pillSpacing: CGFloat = 8
        static let chipSpacing: CGFloat = 8
        static let chipPadding: CGFloat = 10
        static let gridSpacing: CGFloat = 6
        static let weekdayRowSpacing: CGFloat = 4
        static let calendarSpacing: CGFloat = 12
        static let footerSpacing: CGFloat = 4
    }

    enum Tracking {
        static let sectionLabel: CGFloat = 1.2
    }

    enum Opacity {
        static let headerBubble: Double = 0.06
        static let headerPill: Double = 0.12
        static let headerGreeting: Double = 0.7
        static let outsideMonth: Double = 0.3
        static let chipBorder: Double = 0.18
    }
}
