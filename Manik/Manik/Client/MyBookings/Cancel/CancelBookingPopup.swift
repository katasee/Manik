import SwiftUI

struct CancelBookingPopup: View {
    @State private var viewModel: CancelBookingViewModel

    let onDismiss: () -> Void

    init(
        viewModel: CancelBookingViewModel,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "common.action.back",
            onDismiss: onDismiss
        ) { dismiss in
            Text("myBookings.cancel.title")
                .font(.elmsSans(.bold, 18))
                .foregroundStyle(Color.ink)

            summaryCard

            Text("myBookings.cancel.note")
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            failureText

            HStack {
                PopupDismissButton(titleKey: "common.action.back", action: dismiss)

                Spacer()

                PopupPrimaryButton(
                    titleKey: "myBookings.cancel.confirm",
                    color: .destructive,
                    isLoading: viewModel.isCancelling,
                    action: { cancel(dismiss: dismiss) }
                )
            }
        }
        .animation(PopupContainerLayout.fade, value: viewModel.hasFailed)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.cardContentSpacing) {
            Text(verbatim: viewModel.serviceName)
                .font(.elmsSans(.semiBold, 17))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(verbatim: viewModel.slotLabel)
                .font(.elmsSans(.regular, 14))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MyBookingsMetrics.Spacing.cardPadding)
        .background(
            Color.surface,
            in: .rect(cornerRadius: MyBookingsMetrics.Size.cardCornerRadius)
        )
    }

    @ViewBuilder
    private var failureText: some View {
        if viewModel.hasFailed {
            Text("myBookings.error.generic")
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func cancel(dismiss: @escaping () -> Void) {
        Task { @MainActor in
            if await viewModel.cancel() {
                dismiss()
            }
        }
    }
}

#if DEBUG
#Preview("Підтвердження") {
    Color.background
        .overlay {
            CancelBookingPopup(
                viewModel: CancelBookingViewModel(
                    context: CancelBookingContext(
                        id: "mine-1",
                        serviceName: "Класичний манікюр",
                        dayLabel: "20 серпня",
                        timeRangeLabel: "14:00 – 15:30"
                    ),
                    blockRepository: FakeBlockRepository(blocks: MyBookingsPreviewData.blocks)
                ),
                onDismiss: {}
            )
        }
}

#Preview("Помилка") {
    Color.background
        .overlay {
            CancelBookingPopup(
                viewModel: CancelBookingViewModel(
                    context: CancelBookingContext(
                        id: "mine-1",
                        serviceName: "Класичний манікюр",
                        dayLabel: "20 серпня",
                        timeRangeLabel: "14:00 – 15:30"
                    ),
                    blockRepository: FailingBlockRepository()
                ),
                onDismiss: {}
            )
        }
}
#endif
