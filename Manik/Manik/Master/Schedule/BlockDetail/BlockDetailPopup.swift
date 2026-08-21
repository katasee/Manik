import SwiftUI

struct BlockDetailPopup: View {
    @State private var viewModel: BlockDetailViewModel

    private let context: BlockDetailContext
    private let onDismiss: () -> Void

    init(
        context: BlockDetailContext,
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        onDismiss: @escaping () -> Void
    ) {
        self.context = context
        self.onDismiss = onDismiss
        _viewModel = State(
            initialValue: BlockDetailViewModel(
                block: context.block,
                blockRepository: blockRepository
            )
        )
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "schedule.detail.close",
            onDismiss: onDismiss
        ) { dismiss in
            header

            Color.surface
                .frame(height: 1)

            rows

            errorText

            actions(dismiss: dismiss)
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "schedule.detail.close", action: dismiss)

            Spacer()

            ForEach(viewModel.availableActions) { action in
                BlockActionButton(
                    action: action,
                    isLoading: viewModel.runningAction == action,
                    isEnabled: viewModel.isBusy == false,
                    perform: viewModel.perform,
                    onSuccess: dismiss
                )
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Detail.headerSpacing) {
            Text(context.block.timeRangeLabel)
                .font(.elmsSans(.bold, 22))
                .foregroundStyle(Color.ink)

            BlockStatusPill(status: context.block.status)
        }
    }

    @ViewBuilder
    private var rows: some View {
        if context.block.status == .available {
            BlockDetailRow(
                labelKey: "schedule.detail.services",
                value: context.offeredServiceNames
            )
        } else {
            BlockDetailRow(
                labelKey: "schedule.detail.service",
                value: context.bookedServiceName
            )
        }
    }

    @ViewBuilder
    private var errorText: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
        }
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            BlockDetailPopup(
                context: SchedulePreviewData.detailContext(for: SchedulePreviewData.blocks[1]),
                blockRepository: FakeBlockRepository(),
                onDismiss: {}
            )
        }
}
#endif
