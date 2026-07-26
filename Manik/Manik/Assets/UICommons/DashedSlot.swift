import SwiftUI

struct DashedSlot: View {
    let title: LocalizedStringKey
    let action: () -> Void

    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1.5
        static let dash: [CGFloat] = [5, 4]
        static let padding: CGFloat = 9
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.elmsSans(.semiBold, 12.5))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(Layout.padding)
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .strokeBorder(
                            Color.surface,
                            style: StrokeStyle(lineWidth: Layout.borderWidth, dash: Layout.dash)
                        )
                }
                .contentShape(.rect(cornerRadius: Layout.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashedSlot(title: "+ Add free time", action: {})
        .padding()
        .background(Color.background)
}
