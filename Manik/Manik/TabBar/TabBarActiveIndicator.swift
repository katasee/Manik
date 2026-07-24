import SwiftUI

struct TabBarActiveIndicator: View {
    let isActive: Bool
    let namespace: Namespace.ID

    var body: some View {
        if isActive {
            Circle()
                .fill(Color.background)
                .matchedGeometryEffect(id: "activeTabCircle", in: namespace)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace

    TabBarActiveIndicator(isActive: true, namespace: namespace)
        .frame(width: TabBarMetrics.Size.activeCircleDiameter, height: TabBarMetrics.Size.activeCircleDiameter)
        .padding()
        .background(Color.ink)
}
