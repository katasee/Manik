import CoreGraphics

enum ServicesMetrics {
    enum Size {
        static let rowCornerRadius: CGFloat = 24
        static let rowIcon: CGFloat = 36
        static let rowIconGlyph: CGFloat = 13
        static let rowIconBorder: CGFloat = 1
        static let addButton: CGFloat = 52
        static let addIcon: CGFloat = 20
        static let backIcon: CGFloat = 26
        static let backTapTarget: CGFloat = 44
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let introTopPadding: CGFloat = 8
        static let sectionTopPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 6
        static let listTopPadding: CGFloat = 12
        static let rowSpacing: CGFloat = 12
        static let rowTextSpacing: CGFloat = 3
        static let rowContentSpacing: CGFloat = 12
        static let rowHorizontalPadding: CGFloat = 14
        static let rowVerticalPadding: CGFloat = 14
    }

    enum Tracking {
        static let sectionLabel: CGFloat = 1.2
    }
}
