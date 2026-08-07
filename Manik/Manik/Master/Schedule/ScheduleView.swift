import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    @State private var popup: SchedulePopup?

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                title
                date
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)

            WeekDayStrip(selectedDate: $viewModel.selectedDate)
                .padding(.vertical, 12)

            Color.surface
                .frame(height: 1)

            HourlyTimelineView(
                blocks: viewModel.scheduledBlocks,
                freeHours: viewModel.freeHours,
                onTapHour: requestSlotCreation,
                onTapBlock: showBlockDetail,
                onDeleteBlock: deleteBlock
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            await viewModel.observeBlocks()
        }
        .task {
            await viewModel.observeServices()
        }
        .alert(
            "schedule.alert.deleteFailed",
            isPresented: $viewModel.deletionFailed
        ) {
            Button("common.action.ok", role: .cancel) {}
        }
        .alert(
            "schedule.confirm.deleteBooked.title",
            isPresented: $viewModel.isConfirmingDeletion
        ) {
            Button("common.action.cancel", role: .cancel) {}
            Button("schedule.action.delete", role: .destructive) {
                viewModel.confirmPendingDeletion()
            }
        } message: {
            Text("schedule.confirm.deleteBooked.message")
        }
        .fullScreenCover(item: $popup) { popup in
            switch popup {
            case .createSlot(let context):
                AddNewSlotBlock(
                    date: context.date,
                    startHour: context.startHour,
                    services: context.services,
                    onDismiss: dismissPopup
                )
                .presentationBackground(.clear)

            case .blockDetail(let context):
                BlockDetailPopup(context: context, onDismiss: dismissPopup)
                    .presentationBackground(.clear)
            }
        }
    }

    private var title: some View {
        Text("schedule.title")
            .font(.elmsSans(.bold, 28))
            .foregroundStyle(Color.ink)
    }

    private var date: some View {
        Text(DateFormat.monthYear.string(from: viewModel.selectedDate).capitalized)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.textSecondary)
    }

    private func deleteBlock(_ block: Block) {
        viewModel.requestDeletion(of: block)
    }

    private func requestSlotCreation(at hour: Int) {
        withoutPresentationAnimation {
            popup = .createSlot(
                CreateBlockContext(
                    date: viewModel.selectedDate,
                    startHour: hour,
                    services: viewModel.services
                )
            )
        }
    }

    private func showBlockDetail(for scheduled: ScheduledBlock) {
        withoutPresentationAnimation {
            popup = .blockDetail(BlockDetailContext(scheduled))
        }
    }

    private func dismissPopup() {
        withoutPresentationAnimation {
            popup = nil
        }
    }
}

#if DEBUG
#Preview {
    ScheduleView(
        viewModel: ScheduleViewModel(
            blockRepository: FakeBlockRepository(blocks: SchedulePreviewData.blocks),
            serviceRepository: FakeServiceRepository(services: SchedulePreviewData.services)
        )
    )
}
#endif
