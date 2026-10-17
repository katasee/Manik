import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    @State private var openRowId: String?
    @State private var fillMonth: FillMonthViewModel?
    @State private var jumpToDate: JumpToDateViewModel?

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            LargeTitleHeader(titleKey: "schedule.title") {
                RoundIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "schedule.action.addSlots",
                    action: openFillMonth
                )
                .disabled(viewModel.canFillMonth == false)
            }

            ScheduleMonthButton(title: viewModel.monthTitle, action: openJumpToDate)

            WeekDayStrip(selectedDate: $viewModel.selectedDate)
                .padding(.vertical, ScheduleMetrics.Spacing.stripVerticalPadding)

            TimelineView(.everyMinute) { context in
                content(viewModel.items(now: context.date))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .simultaneousGesture(TapGesture().onEnded(closeOpenRow))
        .task {
            await viewModel.observeSlots()
        }
        .onChange(of: viewModel.selectedDate, closeOpenRow)
        .fullScreenCover(item: $fillMonth) { fillMonth in
            FillMonthPopup(viewModel: fillMonth, onDismiss: closeFillMonth)
                .presentationBackground(.clear)
        }
        .fullScreenCover(item: $jumpToDate) { jumpToDate in
            JumpToDatePopup(
                viewModel: jumpToDate,
                onPick: viewModel.select(dayId:),
                onDismiss: closeJumpToDate
            )
            .presentationBackground(.clear)
        }
    }

    private func content(_ items: [SlotItem]) -> some View {
        ZStack {
            if items.isEmpty == false {
                list(items)
            }

            ListStatusOverlay(
                hasLoaded: viewModel.hasLoaded,
                isEmpty: items.isEmpty,
                titleKey: emptyTitleKey,
                messageKey: emptyMessageKey
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitleKey: LocalizedStringKey {
        viewModel.hasFailed ? "schedule.loadFailed.title" : "schedule.empty.title"
    }

    private var emptyMessageKey: LocalizedStringKey {
        viewModel.hasFailed ? "schedule.loadFailed.message" : "schedule.empty.message"
    }

    private func list(_ items: [SlotItem]) -> some View {
        ScrollView {
            LazyVStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
                ForEach(items) { item in
                    SwipeToDelete(
                        id: item.id,
                        openId: $openRowId,
                        cornerRadius: ScheduleMetrics.Size.rowCornerRadius,
                        onDelete: { delete(item) }
                    ) {
                        FreeSlotRow(item: item)
                            .accessibilityAction(named: Text("schedule.action.deleteSlot")) {
                                delete(item)
                            }
                    }
                }
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.horizontalPadding)
            .padding(.top, ScheduleMetrics.Spacing.listTopPadding)
            .padding(.bottom, ScheduleMetrics.Spacing.contentBottomPadding)
        }
        .scrollIndicators(.hidden)
    }

    private func closeOpenRow() {
        openRowId = nil
    }

    private func openFillMonth() {
        withoutPresentationAnimation {
            fillMonth = viewModel.makeFillMonthViewModel()
        }
    }

    private func closeFillMonth() {
        withoutPresentationAnimation {
            fillMonth = nil
        }
    }

    private func openJumpToDate() {
        withoutPresentationAnimation {
            jumpToDate = viewModel.makeJumpToDateViewModel()
        }
    }

    private func closeJumpToDate() {
        withoutPresentationAnimation {
            jumpToDate = nil
        }
    }

    private func delete(_ item: SlotItem) {
        viewModel.delete(id: item.id)
    }
}

#if DEBUG
#Preview {
    ScheduleView(
        viewModel: ScheduleViewModel(
            slotRepository: FakeSlotRepository(slots: SchedulePreviewData.slots)
        )
    )
}
#endif
