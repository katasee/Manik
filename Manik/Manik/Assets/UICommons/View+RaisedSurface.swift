import SwiftUI

private enum RaisedSurfaceLayout {
    static let contourOpacity: Double = 0.06
    static let contourWidth: CGFloat = 1
    static let sheenOpacity: Double = 0.06
    static let rimOpacity: Double = 0.18
}

struct RaisedSurface<S: InsettableShape>: ViewModifier {
    let shape: S

    func body(content: Content) -> some View {
        content
            .background {
                shape
                    .fill(Color.raised)
                    .overlay {
                        shape
                            .fill(
                                LinearGradient(
                                    colors: [Color.highlight.opacity(RaisedSurfaceLayout.sheenOpacity), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .raisedShadow()
            }
            .overlay {
                shape
                    .strokeBorder(
                        Color.ink.opacity(RaisedSurfaceLayout.contourOpacity),
                        lineWidth: RaisedSurfaceLayout.contourWidth
                    )
                    .allowsHitTesting(false)
            }
            .overlay {
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.highlight.opacity(RaisedSurfaceLayout.rimOpacity), .clear],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: RaisedSurfaceLayout.contourWidth
                    )
                    .allowsHitTesting(false)
            }
    }
}

extension View {
    func raisedSurface<S: InsettableShape>(_ shape: S) -> some View {
        modifier(RaisedSurface(shape: shape))
    }
}

#Preview {
    HStack(spacing: 16) {
        Text(verbatim: "10:00")
            .font(.elmsSans(.semiBold, 15))
            .frame(minWidth: 72, minHeight: 44)
            .raisedSurface(.capsule)

        Image(systemName: "chevron.right")
            .font(.elmsSans(.medium, 16))
            .frame(width: 44, height: 44)
            .raisedSurface(.circle)

        Image(systemName: "clock")
            .font(.elmsSans(.medium, 17))
            .frame(width: 40, height: 40)
            .raisedSurface(.rect(cornerRadius: 12))
    }
    .foregroundStyle(Color.ink)
    .padding()
    .background(Color.background)
}
