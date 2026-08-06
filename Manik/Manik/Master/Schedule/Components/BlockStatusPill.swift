import SwiftUI

struct BlockStatusPill: View {
    let status: BlockStatus

    var body: some View {
        Text(status.textKey)
            .font(.elmsSans(.bold, 12))
            .foregroundStyle(.white)
            .padding(.horizontal, ScheduleMetrics.StatusPill.horizontalPadding)
            .padding(.vertical, ScheduleMetrics.StatusPill.verticalPadding)
            .background(status.accentColor, in: .capsule)
    }
}

#Preview {
    HStack {
        BlockStatusPill(status: .available)
        BlockStatusPill(status: .pending)
        BlockStatusPill(status: .confirmed)
    }
    .padding()
    .background(Color.background)
}
