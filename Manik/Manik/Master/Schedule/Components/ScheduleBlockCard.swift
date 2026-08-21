import SwiftUI

struct ScheduleBlockCard: View {
    let block: Block
    let serviceNames: String

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Card.contentSpacing) {
            Text(block.timeRangeLabel)
                .font(.elmsSans(.bold, 17))
                .foregroundStyle(Color.ink)

            if serviceNames.isEmpty == false {
                Text(serviceNames)
                    .font(.elmsSans(.regular, 12))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.leading, ScheduleMetrics.Card.leadingPadding)
        .padding(.trailing, ScheduleMetrics.Card.trailingPadding)
        .padding(.vertical, ScheduleMetrics.Card.verticalPadding)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(
            Color.fieldBackground,
            in: .rect(cornerRadius: ScheduleMetrics.Card.cornerRadius)
        )
        .overlay(alignment: .leading) {
            Capsule()
                .fill(block.status.accentColor)
                .frame(width: ScheduleMetrics.Card.accentWidth)
                .padding([.vertical, .leading], ScheduleMetrics.Card.accentInset)
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        ForEach(SchedulePreviewData.scheduledBlocks) { item in
            ScheduleBlockCard(block: item.block, serviceNames: item.serviceNames)
                .frame(height: ScheduleMetrics.Size.hourHeight)
                .cardShadow()
        }
    }
    .padding()
    .background(Color.background)
}
#endif
