import SwiftUI

struct HourlyTimelineView: View {
    let blocks: [ScheduledBlock]
    let freeHours: Set<Int>
    let onTapHour: (Int) -> Void
    let onDeleteBlock: (Block) -> Void

    @State private var openBlockId: String?

    private let geometry = TimelineGeometry(
        hourHeight: ScheduleMetrics.Size.hourHeight,
        firstHour: SalonHours.working.lowerBound
    )

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                TimelineHourGrid(geometry: geometry)

                TimelineFreeSlots(
                    freeHours: freeHours,
                    geometry: geometry,
                    onTapHour: onTapHour
                )

                TimelineBlockCards(
                    blocks: blocks,
                    geometry: geometry,
                    openBlockId: $openBlockId,
                    onDelete: onDeleteBlock
                )
            }
            .padding(.vertical, ScheduleMetrics.Spacing.rowSpacing)
            .padding(.bottom, ScheduleMetrics.Spacing.timelineBottomSlack)
            .contentShape(.rect)
            .onTapGesture(perform: closeOpenCard)
        }
        .scrollIndicators(.hidden)
    }

    private func closeOpenCard() {
        openBlockId = nil
    }
}

#if DEBUG
#Preview {
    HourlyTimelineView(
        blocks: SchedulePreviewData.scheduledBlocks,
        freeHours: SchedulePreviewData.freeHours,
        onTapHour: { _ in },
        onDeleteBlock: { _ in }
    )
    .background(Color.background)
}
#endif
