import SwiftUI

struct TabBarBadge: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.elmsSans(.bold, 11))
            .foregroundStyle(.white)
            .frame(minWidth: TabBarMetrics.Size.badgeDiameter, minHeight: TabBarMetrics.Size.badgeDiameter)
            .background(Color.badge, in: .circle)
    }
}

#Preview {
    TabBarBadge(count: 2)
        .padding()
        .background(Color.ink)
}
