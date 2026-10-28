import SwiftUI

struct CardSurface: ViewModifier {
    let fill: Color
    let padding: CGFloat
    let cornerRadius: CGFloat
    let fillsHeight: Bool

    private enum Layout {
        static let contourOpacity: Double = 0.045
        static let contourWidth: CGFloat = 1
        static let sheenOpacity: Double = 0.04
        static let rimOpacity: Double = 0.14
    }

    func body(content: Content) -> some View {
        padded(content)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fill)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [Color.highlight.opacity(Layout.sheenOpacity), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .cardShadow()
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        Color.ink.opacity(Layout.contourOpacity),
                        lineWidth: Layout.contourWidth
                    )
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.highlight.opacity(Layout.rimOpacity), .clear],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: Layout.contourWidth
                    )
                    .allowsHitTesting(false)
            }
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
        fill: Color = .card,
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
