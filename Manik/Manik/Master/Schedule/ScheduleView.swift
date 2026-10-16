import SwiftUI

struct ScheduleView: View {
    @State private var selectedDate = Date.now

    let items: [SlotItem]
    let hasLoaded: Bool

    var body: some View {
        VStack(spacing: 0) {
            LargeTitleHeader(titleKey: "schedule.title", subtitle: monthTitle) {
                RoundIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "schedule.action.addSlots",
                    action: {}
                )
            }

            WeekDayStrip(selectedDate: $selectedDate)
                .padding(.vertical, ScheduleMetrics.Spacing.stripVerticalPadding)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }

    private var monthTitle: String {
        DateFormat.monthYear.string(from: selectedDate).capitalized
    }

    private var content: some View {
        ZStack {
            if items.isEmpty == false {
                list
            }

            ListStatusOverlay(
                hasLoaded: hasLoaded,
                isEmpty: items.isEmpty,
                titleKey: "schedule.empty.title",
                messageKey: "schedule.empty.message"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
                ForEach(items) { item in
                    FreeSlotRow(item: item)
                }
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.horizontalPadding)
            .padding(.top, ScheduleMetrics.Spacing.listTopPadding)
            .padding(.bottom, ScheduleMetrics.Spacing.contentBottomPadding)
        }
        .scrollIndicators(.hidden)
    }
}

#if DEBUG
#Preview {
    ScheduleView(items: SchedulePreviewData.items, hasLoaded: true)
}
#endif
