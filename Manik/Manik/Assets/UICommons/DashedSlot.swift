import SwiftUI

struct DashedSlot: View {
    let title: LocalizedStringKey
    let action: () -> Void

    private enum Layout {
        static let cornerRadius: CGFloat = 14
        static let borderWidth: CGFloat = 1.5
        static let dash: [CGFloat] = [5, 4]
        static let height: CGFloat = 40
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.elmsSans(.medium, 13))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, minHeight: Layout.height)
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .strokeBorder(
                            Color.stroke,
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
