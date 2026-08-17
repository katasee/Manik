import SwiftUI

struct BookingDatesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BookingDatesViewModel
    @State private var confirmContext: BookingConfirmContext?

    let bottomClearance: CGFloat
    let onBooked: () -> Void

    init(
        viewModel: BookingDatesViewModel,
        bottomClearance: CGFloat,
        onBooked: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.bottomClearance = bottomClearance
        self.onBooked = onBooked
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(titleKey: "booking.dates.title", onBack: goBack)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { footer }
        .fullScreenCover(item: $confirmContext) { context in
            BookingConfirmPopup(
                viewModel: viewModel.makeConfirmViewModel(context: context),
                onDismiss: dismissConfirm,
                onFinish: finishConfirm
            )
            .presentationBackground(.clear)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: BookingMetrics.Spacing.calendarSpacing) {
                MonthHeader(
                    title: viewModel.month.title,
                    canGoBack: viewModel.month.canGoBack,
                    onPrevious: viewModel.goToPreviousMonth,
                    onNext: viewModel.goToNextMonth
                )

                MonthGrid(
                    month: viewModel.month,
                    selectedDate: viewModel.selectedDate,
                    onSelect: { viewModel.select(day: $0) }
                )

                timeSection
            }
            .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
            .padding(.top, BookingMetrics.Spacing.listTopPadding)
        }
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: BookingMetrics.Spacing.chipSpacing) {
            Text("booking.calendar.pickTime")
                .font(.elmsSans(.medium, 12))
                .textCase(.uppercase)
                .tracking(BookingMetrics.Tracking.sectionLabel)
                .foregroundStyle(Color.textSecondary)

            slotRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, BookingMetrics.Spacing.sectionTopPadding)
    }

    @ViewBuilder
    private var slotRow: some View {
        if viewModel.daySlots.isEmpty {
            Text("booking.calendar.noSlots")
                .font(.elmsSans(.regular, 14))
                .foregroundStyle(Color.textSecondary)
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: BookingMetrics.Spacing.chipSpacing) {
                    ForEach(viewModel.daySlots) { slot in
                        Button {
                            viewModel.select(slot: slot)
                        } label: {
                            SlotChip(
                                slot: slot,
                                isSelected: slot.id == viewModel.selectedSlot?.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            if let slotLabel = viewModel.slotLabel {
                ConfirmBar(
                    serviceName: viewModel.serviceName,
                    slotLabel: slotLabel,
                    priceLabel: viewModel.priceLabel,
                    action: presentConfirm
                )
                .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
                .padding(.bottom, BookingMetrics.Spacing.cardPadding)
            }
        }
        .padding(.bottom, bottomClearance)
    }

    private func goBack() {
        dismiss()
    }

    private func presentConfirm() {
        guard let context = viewModel.confirmContext else { return }

        withoutPresentationAnimation {
            confirmContext = context
        }
    }

    private func dismissConfirm() {
        withoutPresentationAnimation {
            confirmContext = nil
        }
    }

    private func finishConfirm() {
        dismissConfirm()
        onBooked()
    }
}

#if DEBUG
#Preview {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return NavigationStack {
        BookingDatesView(
            viewModel: BookingDatesViewModel(
                offer: offers[0],
                clientId: BookingPreviewData.clientId,
                blockRepository: FakeBlockRepository(blocks: BookingPreviewData.blocks)
            ),
            bottomClearance: 0,
            onBooked: {}
        )
    }
}
#endif
