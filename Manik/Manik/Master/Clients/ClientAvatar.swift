import SwiftUI

struct ClientAvatar: View {
    let initial: String
    let size: CGFloat

    private enum Layout {
        static let glyphRatio: CGFloat = 0.36
    }

    var body: some View {
        Text(verbatim: initial)
            .font(.elmsSans(.semiBold, size * Layout.glyphRatio))
            .foregroundStyle(Color.wine)
            .frame(width: size, height: size)
            .background(Color.wineSoft, in: .circle)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        ClientAvatar(initial: "О", size: 44)
        ClientAvatar(initial: "S", size: 84)
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
#endif
