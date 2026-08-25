import SwiftUI

struct BlockStatusPill: View {
    let status: BlockStatus

    private enum Layout {
        static let text: CGFloat = 12
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 3
        static let fill: Double = 0.22
    }

    var body: some View {
        Text(status.textKey)
            .font(.elmsSans(.bold, Layout.text))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            .background(status.accentColor.opacity(Layout.fill), in: .capsule)
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
