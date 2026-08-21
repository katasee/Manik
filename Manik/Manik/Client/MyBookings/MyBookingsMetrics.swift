import CoreGraphics

enum MyBookingsMetrics {
    enum Size {
        static let cardCornerRadius: CGFloat = 24
        static let accentWidth: CGFloat = 4
        static let accentInset: CGFloat = 12
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let listTopPadding: CGFloat = 12
        static let listSpacing: CGFloat = 14
        static let sectionSpacing: CGFloat = 24
        static let cardPadding: CGFloat = 16
        static let cardLeadingPadding: CGFloat = 28
        static let cardContentSpacing: CGFloat = 6
        static let inlineSpacing: CGFloat = 8
    }

    enum Tracking {
        static let sectionLabel: CGFloat = 1.2
    }

    enum Opacity {
        static let pastAccent: Double = 0.5
    }
}
