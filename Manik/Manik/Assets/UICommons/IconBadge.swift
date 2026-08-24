import SwiftUI

struct IconBadge: View {
    let systemName: String
    let tint: Color

    private enum Layout {
        static let size: CGFloat = 40
        static let cornerRadius: CGFloat = 12
        static let icon: CGFloat = 17
        static let fill: Double = 0.15
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.elmsSans(.semiBold, Layout.icon))
            .foregroundStyle(tint)
            .frame(width: Layout.size, height: Layout.size)
            .background(
                tint.opacity(Layout.fill),
                in: .rect(cornerRadius: Layout.cornerRadius)
            )
    }
}

#Preview {
    HStack(spacing: 12) {
        IconBadge(systemName: "checkmark.circle", tint: Color.statusConfirmed)
        IconBadge(systemName: "clock", tint: Color.statusPending)
        IconBadge(systemName: "person.2", tint: Color.freeSlot)
        IconBadge(systemName: "square.dashed", tint: Color.statusAvailable)
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
