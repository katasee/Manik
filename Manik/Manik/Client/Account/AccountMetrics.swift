import CoreGraphics

enum AccountMetrics {
    enum Size {
        static let cardCornerRadius: CGFloat = 24
        static let fieldCornerRadius: CGFloat = 12
        static let avatar: CGFloat = 64
        static let rowIcon: CGFloat = 20
        static let rowHeight: CGFloat = 44
        static let tapTarget: CGFloat = 44
        static let successIcon: CGFloat = 44
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let contentTopPadding: CGFloat = 12
        static let contentBottomPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 24
        static let cardPadding: CGFloat = 16
        static let actionPadding: CGFloat = 14
        static let fieldPadding: CGFloat = 12
        static let cardContentSpacing: CGFloat = 4
        static let rowSpacing: CGFloat = 12
        static let cardSpacing: CGFloat = 14
        static let inlineSpacing: CGFloat = 12
        static let prefixSpacing: CGFloat = 4
    }
}
