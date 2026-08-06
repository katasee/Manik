import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    @State private var creatingBlockContext: CreateBlockContext?

    init(viewModel: ScheduleViewModel? = nil) {
        _viewModel = State(
            initialValue: viewModel ?? ScheduleViewModel(serviceRepository: Self.serviceRepository)
        )
    }

    private static var serviceRepository: ServiceRepository {
        #if DEBUG
        FakeServiceRepository(services: SchedulePreviewData.services)
        #else
        FirestoreServiceRepository()
        #endif
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
        .fullScreenCover(item: $creatingBlockContext) { context in
            AddNewSlotBlock(
                date: context.date,
                startHour: context.startHour,
                services: context.services,
                onDismiss: dismissSlotCreation
            )
            .presentationBackground(.clear)
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
        Task {
            await viewModel.delete(block)
        }
    }

    private func requestSlotCreation(at hour: Int) {
        withoutPresentationAnimation {
            creatingBlockContext = CreateBlockContext(
                date: viewModel.selectedDate,
                startHour: hour,
                services: viewModel.services
            )
        }
    }

    private func dismissSlotCreation() {
        withoutPresentationAnimation {
            creatingBlockContext = nil
        }
    }

    private func withoutPresentationAnimation(_ changes: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction, changes)
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
