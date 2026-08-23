import SwiftUI

struct CardSurface: ViewModifier {
    let fill: Color
    let padding: CGFloat
    let cornerRadius: CGFloat
    let fillsHeight: Bool

    func body(content: Content) -> some View {
        padded(content)
            .background(fill, in: .rect(cornerRadius: cornerRadius))
            .cardShadow()
    }

    @ViewBuilder
    private func padded(_ content: Content) -> some View {
        if fillsHeight {
            content
                .padding(padding)
                .frame(maxHeight: .infinity, alignment: .top)
        } else {
            content
                .padding(padding)
        }
    }
}

extension View {
    func cardSurface(
        fill: Color = .fieldBackground,
        padding: CGFloat,
        cornerRadius: CGFloat,
        fillsHeight: Bool = false
    ) -> some View {
        modifier(
            CardSurface(
                fill: fill,
                padding: padding,
                cornerRadius: cornerRadius,
                fillsHeight: fillsHeight
            )
        )
    }
}

#Preview {
    VStack(spacing: 14) {
        Text(verbatim: "Звичайна картка")
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface(padding: 16, cornerRadius: 24)

        HStack(spacing: 14) {
            Text(verbatim: "Низька")
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardSurface(padding: 16, cornerRadius: 24, fillsHeight: true)

            Text(verbatim: "Висока\nу два\nрядки")
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardSurface(padding: 16, cornerRadius: 24, fillsHeight: true)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    .font(.elmsSans(.medium, 15))
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
