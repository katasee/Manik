import CoreGraphics

enum PlansMetrics {
    enum Size {
        static let rowCornerRadius: CGFloat = 24
        static let emojiTile: CGFloat = 44
        static let emojiTileCornerRadius: CGFloat = 14
        static let emojiGlyph: CGFloat = 22
        static let pickedTile: CGFloat = 56
        static let pickedTileCornerRadius: CGFloat = 18
        static let pickedGlyph: CGFloat = 28
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let sectionTopPadding: CGFloat = 24
        static let listTopPadding: CGFloat = 12
        static let listBottomPadding: CGFloat = 24
        static let rowSpacing: CGFloat = 12
        static let rowContentSpacing: CGFloat = 14
        static let rowHorizontalPadding: CGFloat = 14
        static let rowVerticalPadding: CGFloat = 12
    }

    enum Opacity {
        static let inactiveGlyph: Double = 0.4
    }
}
