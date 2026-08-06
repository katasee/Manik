import SwiftUI

enum ScheduleMetrics {
    enum Size {
        static let hourLabelWidth: CGFloat = 48
        static let hourLabelCentering: CGFloat = 10
        static let hourHeight: CGFloat = 84
    }

    enum Spacing {
        static let rowSpacing: CGFloat = 16
        static let timelineHorizontalPadding: CGFloat = 16
        static let timelineBottomSlack: CGFloat = 64
        static let contentLeadingPadding: CGFloat = timelineHorizontalPadding + Size.hourLabelWidth
    }

    enum Card {
        static let cornerRadius: CGFloat = 18
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let contentSpacing: CGFloat = 4
        static let accentWidth: CGFloat = 4
        static let accentInset: CGFloat = 10
        static let overlapIndent: CGFloat = 16
        static let verticalInset: CGFloat = 6
        static let minHeight: CGFloat = 64
    }

    enum CreatePopup {
        static let fade = Animation.easeOut(duration: 0.2)
        static let cornerRadius: CGFloat = 20
        static let cardPadding: CGFloat = 20
        static let rowSpacing: CGFloat = 16
        static let defaultDurationMinutes = 60
    }
}
