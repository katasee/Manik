import SwiftUI

struct TimelineBlockCards: View {
    let blocks: [ScheduledBlock]
    let geometry: TimelineGeometry
    @Binding var openBlockId: String?
    let onTap: (ScheduledBlock) -> Void
    let onDelete: (Block) -> Void

    var body: some View {
        ForEach(blocks) { item in
            SwipeToDelete(
                id: item.id,
                openId: $openBlockId,
                cornerRadius: ScheduleMetrics.Card.cornerRadius,
                onDelete: { onDelete(item.block) }
            ) {
                ScheduleBlockCard(block: item.block, serviceNames: item.serviceNames)
                    .contentShape(.rect)
                    .onTapGesture { handleTap(item) }
                    .accessibilityAddTraits(.isButton)
            }
            .cardShadow()
            .padding(.leading, leadingPadding(depth: item.depth))
            .padding(.trailing, ScheduleMetrics.Spacing.timelineHorizontalPadding)
            .padding(.vertical, ScheduleMetrics.Card.verticalInset)
            .frame(
                height: geometry.height(for: item.block, minimum: ScheduleMetrics.Card.minHeight),
                alignment: .top
            )
            .offset(y: geometry.offset(for: item.block))
            .zIndex(Double(item.depth))
        }
    }

    private func handleTap(_ item: ScheduledBlock) {
        guard openBlockId == nil else {
            openBlockId = nil
            return
        }

        onTap(item)
    }

    private func leadingPadding(depth: Int) -> CGFloat {
        ScheduleMetrics.Spacing.contentLeadingPadding
            + CGFloat(depth) * ScheduleMetrics.Card.overlapIndent
    }
}

#if DEBUG
#Preview {
    @Previewable @State var openBlockId: String?

    TimelineBlockCards(
        blocks: SchedulePreviewData.scheduledBlocks,
        geometry: TimelineGeometry(
            hourHeight: ScheduleMetrics.Size.hourHeight,
            firstHour: WorkHours.working.lowerBound
        ),
        openBlockId: $openBlockId,
        onTap: { _ in },
        onDelete: { _ in }
    )
    .background(Color.background)
}
#endif
