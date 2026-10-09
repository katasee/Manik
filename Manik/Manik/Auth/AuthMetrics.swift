import SwiftUI

enum AuthMetrics {
    enum FontSize {
        static let title: CGFloat = 50
        static let tagline: CGFloat = 18
        static let fieldLabel: CGFloat = 12
        static let submitLabel: CGFloat = 15
        static let error: CGFloat = 13
        static let swap: CGFloat = 14
        static let labelTracking: CGFloat = 0.5
        static let verifyTitle: CGFloat = 32
        static let verifyBody: CGFloat = 15
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 26
        static let screenVertical: CGFloat = 34
        static let fieldStack: CGFloat = 16
        static let fieldLabelToBox: CGFloat = 6
        static let taglineBottom: CGFloat = 28
        static let errorTop: CGFloat = 12
        static let submitTop: CGFloat = 12
        static let submitVerticalPadding: CGFloat = 15
        static let swapTop: CGFloat = 8
        static let swapSpacing: CGFloat = 4
        static let verifyIconBottom: CGFloat = 20
        static let verifyMessageTop: CGFloat = 10
        static let verifyButtonsTop: CGFloat = 28
        static let verifyButtons: CGFloat = 12
    }

    enum AnimationStyle {
        static let modeSwitch = Animation.spring(response: 0.35, dampingFraction: 0.7)
    }

    static let disabledOpacity: Double = 0.5
    static let swapTapHeight: CGFloat = 44
}
