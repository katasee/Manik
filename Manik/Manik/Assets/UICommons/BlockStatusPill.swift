import SwiftUI

struct BlockStatusPill: View {
    let status: BlockStatus

    private enum Layout {
        static let text: CGFloat = 12
        static let dot: CGFloat = 6
        static let spacing: CGFloat = 6
        static let leadingPadding: CGFloat = 8
        static let trailingPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 4
        static let outlineWidth: CGFloat = 1
    }

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Circle()
                .frame(width: Layout.dot, height: Layout.dot)
                .accessibilityHidden(true)

            Text(status.textKey)
                .font(.elmsSans(.semiBold, Layout.text))
                .lineLimit(1)
        }
        .foregroundStyle(status.accentColor)
        .padding(.leading, Layout.leadingPadding)
        .padding(.trailing, Layout.trailingPadding)
        .padding(.vertical, Layout.verticalPadding)
        .background {
            Capsule()
                .fill(status.fillColor)
                .stroke(
                    status == .available ? Color.hairline : .clear,
                    lineWidth: Layout.outlineWidth
                )
        }
    }
}

#Preview {
    HStack {
        BlockStatusPill(status: .available)
        BlockStatusPill(status: .pending)
        BlockStatusPill(status: .confirmed)
    }
    .padding()
    .background(Color.background)
}
