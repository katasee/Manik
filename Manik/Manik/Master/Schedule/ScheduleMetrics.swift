import SwiftUI

enum ScheduleMetrics {
    static let workingHours = 8..<22

    enum Size {
        static let hourLabelWidth: CGFloat = 48
    }

    enum Spacing {
        static let rowSpacing: CGFloat = 16
        static let timelineHorizontalPadding: CGFloat = 16
    }

    enum CreatePopup {
        static let cornerRadius: CGFloat = 20
        static let cardPadding: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        static let dimOpacity: Double = 0.4
        static let defaultDurationMinutes = 30
    }
}
