import SwiftUI

enum TabBarMetrics {
    enum Size {
        static let capsuleHeight: CGFloat = 56
        static let activeCircleDiameter: CGFloat = 64
        static let activeCircleLift: CGFloat = 18
        static let iconSize: CGFloat = 22
        static let badgeDiameter: CGFloat = 18
        /// Apple's HIG minimum tap target; `activeCircleDiameter` (64) already exceeds this,
        /// so every `TabBarButton` — active or not — clears it without a separate frame call.
        static let minTapArea: CGFloat = 44
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
