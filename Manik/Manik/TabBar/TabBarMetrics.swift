import SwiftUI

enum TabBarMetrics {
    enum Size {
        static let capsuleHeight: CGFloat = 56
        /// Also doubles as every TabBarButton's fixed tap-target size — already exceeds
        /// Apple's HIG 44×44 minimum, so no separate frame call is needed.
        static let activeCircleDiameter: CGFloat = 64
        static let activeCircleLift: CGFloat = 18
        static let iconSize: CGFloat = 22
        static let badgeDiameter: CGFloat = 18
    }

    enum Spacing {
        static let tabSpacing: CGFloat = 4
        static let innerHorizontalPadding: CGFloat = 12
        static let capsuleHorizontalPadding: CGFloat = 24
        static let bottomInset: CGFloat = 12
    }

    enum Opacity {
        static let inactiveIcon: Double = 0.55
    }

    enum AnimationStyle {
        static let selection = Animation.spring(response: 0.35, dampingFraction: 0.75)
    }
}
