import SwiftUI

struct IconBadge: View {
    let systemName: String

    private enum Layout {
        static let size: CGFloat = 40
        static let cornerRadius: CGFloat = 12
        static let icon: CGFloat = 17
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.elmsSans(.medium, Layout.icon))
            .foregroundStyle(Color.wine)
            .frame(width: Layout.size, height: Layout.size)
            .background(Color.wineSoft, in: .rect(cornerRadius: Layout.cornerRadius))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 12) {
        IconBadge(systemName: "checkmark.circle")
        IconBadge(systemName: "clock")
        IconBadge(systemName: "person.2")
        IconBadge(systemName: "square.dashed")
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
