import SwiftUI

enum TabBarMetrics {
    enum Size {
        static let capsuleHeight: Double = 70
        static let activeCircleDiameter: Double = 70
        static let activeCircleLift: Double = 25
        static let iconSize: Double = 24
        static let badgeDiameter: Double = 14
        static let captionFontSize: Double = 9
        static let activeCircleOverhang: Double = activeCircleLift + captionFontSize
        static let reservedClearance: Double = capsuleHeight + activeCircleOverhang + TabBarMetrics.Spacing.bottomInset
    }

    enum Spacing {
        static let tabSpacing: Double = 4
        static let innerHorizontalPadding: Double = 12
        static let capsuleHorizontalPadding: Double = 20
        static let bottomInset: Double = 8
    }

    enum Offset {
        static let badgeX: Double = 9
        static let badgeY: Double = -7
    }

    enum Opacity {
        static let inactiveIcon: Double = 0.55
    }

    enum AnimationStyle {
        static let selection = Animation.spring(response: 0.35, dampingFraction: 0.75)
    }
}
