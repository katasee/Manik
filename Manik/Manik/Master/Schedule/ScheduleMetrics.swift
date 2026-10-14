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
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let stripVerticalPadding: CGFloat = 12
        static let listTopPadding: CGFloat = 8
        static let rowSpacing: CGFloat = 10
        static let rowHorizontalPadding: CGFloat = 18
        static let contentBottomPadding: CGFloat = 24
    }
}
