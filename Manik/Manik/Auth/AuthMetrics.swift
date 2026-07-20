import SwiftUI

enum AuthMetrics {
    enum FontSize {
        static let title: CGFloat = 50
        static let tagline: CGFloat = 18
        static let fieldLabel: CGFloat = 12
        static let fieldValue: CGFloat = 15
        static let segmentLabel: CGFloat = 13
        static let submitLabel: CGFloat = 15
        static let error: CGFloat = 13
        static let labelTracking: CGFloat = 0.5
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 26
        static let screenVertical: CGFloat = 34
        static let fieldStack: CGFloat = 16
        static let fieldLabelToBox: CGFloat = 6
        static let fieldPadding: CGFloat = 12
        static let modeSwitcherBottom: CGFloat = 20
        static let taglineBottom: CGFloat = 10
        static let errorTop: CGFloat = 12
        static let submitTop: CGFloat = 12
        static let submitVerticalPadding: CGFloat = 15
        static let segmentSpacing: CGFloat = 4
        static let segmentPadding: CGFloat = 16
        static let segmentTrackPadding: CGFloat = 5
    }

    enum CornerRadius {
        static let field: CGFloat = 10
    }

    enum AnimationStyle {
        static let modeSwitch = Animation.spring(response: 0.35, dampingFraction: 0.7)
    }

    static let disabledOpacity: Double = 0.5
}
