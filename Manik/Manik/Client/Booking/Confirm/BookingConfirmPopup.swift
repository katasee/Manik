import SwiftUI

struct BookingConfirmPopup: View {
    @State private var viewModel: BookingConfirmViewModel

    let onDismiss: () -> Void
    let onFinish: () -> Void

    init(
        viewModel: BookingConfirmViewModel,
        onDismiss: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
        self.onFinish = onFinish
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "common.action.cancel",
            onDismiss: exit
        ) { dismiss in
            if viewModel.isBooked {
                bookedContent(dismiss: dismiss)
            } else {
                confirmContent(dismiss: dismiss)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.isBooked)
    }

    @ViewBuilder
    private func confirmContent(dismiss: @escaping () -> Void) -> some View {
        Text("booking.confirm.title")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)

        summaryCard

        Text("booking.confirm.note")
            .font(.elmsSans(.regular, 13))
            .foregroundStyle(Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

        failureText

        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            PopupPrimaryButton(
                titleKey: "booking.action.book",
                color: .ink,
                isLoading: viewModel.isSaving,
                action: book
            )
        }
    }

    @ViewBuilder
    private func bookedContent(dismiss: @escaping () -> Void) -> some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.elmsSans(.bold, BookingMetrics.Size.successIcon))
            .foregroundStyle(Color.freeSlot)

        Text("booking.success.title")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)

        Text("booking.success.message")
            .font(.elmsSans(.regular, 14))
            .foregroundStyle(Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

        HStack {
            Spacer()

            PopupPrimaryButton(
                titleKey: "common.action.done",
                color: .ink,
                isLoading: false,
                action: dismiss
            )
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: BookingMetrics.Spacing.footerSpacing) {
            Text(verbatim: viewModel.serviceName)
                .font(.elmsSans(.semiBold, 17))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(verbatim: viewModel.slotLabel)
                .font(.elmsSans(.regular, 14))
                .foregroundStyle(Color.textSecondary)

            Text(verbatim: viewModel.priceLabel)
                .font(.elmsSans(.bold, 20))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BookingMetrics.Spacing.cardPadding)
        .background(
            Color.surface,
            in: .rect(cornerRadius: BookingMetrics.Size.cardCornerRadius)
        )
    }

    @ViewBuilder
    private var failureText: some View {
        if let failure = viewModel.failure {
            Text(failure.messageKey)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func book() {
        Task {
            await viewModel.book()
        }
    }

    private func exit() {
        if viewModel.isBooked {
            onFinish()
        } else {
            onDismiss()
        }
    }
}

#if DEBUG
#Preview("Підтвердження") {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return Color.background
        .overlay {
            BookingConfirmPopup(
                viewModel: BookingConfirmViewModel(
                    context: BookingConfirmContext(
                        service: offers[0].service,
                        slot: offers[0].nearestDaySlots[0]
                    ),
                    clientId: BookingPreviewData.clientId,
                    blockRepository: FakeBlockRepository(blocks: BookingPreviewData.blocks)
                ),
                onDismiss: {},
                onFinish: {}
            )
        }
}

#Preview("Час зайняли") {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return Color.background
        .overlay {
            BookingConfirmPopup(
                viewModel: BookingConfirmViewModel(
                    context: BookingConfirmContext(
                        service: offers[0].service,
                        slot: offers[0].nearestDaySlots[0]
                    ),
                    clientId: BookingPreviewData.clientId,
                    blockRepository: FakeBlockRepository()
                ),
                onDismiss: {},
                onFinish: {}
            )
        }
}
#endif
