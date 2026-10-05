import SwiftUI

private enum InsetSurfaceLayout {
    static let outlineWidth: CGFloat = 1
}

struct InsetSurface<S: InsettableShape>: ViewModifier {
    let shape: S

    func body(content: Content) -> some View {
        content
            .background(Color.card, in: shape)
            .overlay {
                shape
                    .strokeBorder(Color.hairline, lineWidth: InsetSurfaceLayout.outlineWidth)
                    .allowsHitTesting(false)
            }
    }
}

extension View {
    func insetSurface<S: InsettableShape>(_ shape: S) -> some View {
        modifier(InsetSurface(shape: shape))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 4) {
        Text(verbatim: "Класичний манікюр")
            .font(.elmsSans(.semiBold, 17))
        Text(verbatim: "Пт, 2 жовтня · 14:00 – 15:30")
            .font(.elmsSans(.regular, 14))
            .foregroundStyle(Color.textSecondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .insetSurface(.rect(cornerRadius: 18))
    .padding()
    .background(Color.background)
}
