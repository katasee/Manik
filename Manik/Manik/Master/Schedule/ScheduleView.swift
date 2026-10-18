import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    @State private var openRowId: String?
    @State private var fillMonth: FillMonthViewModel?
    @State private var jumpToDate: JumpToDateViewModel?
    @State private var bookClient: BookClientViewModel?
    @State private var bookingActions: BookingActionsViewModel?
    @State private var pendingCardClientId: String?
    @State private var openCardClientId: String?
    @State private var pendingDelete: SlotItem?
    @State private var isConfirmingDelete = false

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
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
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $openCardClientId) { clientId in
                ClientCardView(viewModel: viewModel.makeClientCardViewModel(clientId: clientId))
            }
            .simultaneousGesture(TapGesture().onEnded(closeOpenRow))
            .task {
                await viewModel.observeSlots()
            }
            .task {
                await viewModel.observeClients()
            }
            .task {
                await viewModel.observeServices()
            }
            .onChange(of: viewModel.selectedDate, closeOpenRow)
            .fullScreenCover(item: $fillMonth) { fillMonth in
                FillMonthPopup(viewModel: fillMonth, onDismiss: closeFillMonth)
                    .presentationBackground(.clear)
            }
            .fullScreenCover(item: $bookClient) { bookClient in
                BookClientPopup(viewModel: bookClient, onDismiss: closeBookClient)
                    .presentationBackground(.clear)
            }
            .fullScreenCover(item: $bookingActions, onDismiss: openPendingCard) { bookingActions in
                BookingActionsPopup(
                    viewModel: bookingActions,
                    onOpenCard: { pendingCardClientId = $0 },
                    onDismiss: closeBookingActions
                )
                .presentationBackground(.clear)
            }
            .alert(
                "schedule.delete.booked.title",
                isPresented: $isConfirmingDelete,
                presenting: pendingDelete
            ) { item in
                Button("schedule.delete.booked.action", role: .destructive) {
                    delete(item)
                }

                Button("common.action.cancel", role: .cancel) {}
            } message: { item in
                Text("schedule.delete.booked.message \(item.booking?.clientName ?? "")")
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
                        onDelete: { requestDelete(item) }
                    ) {
                        ScheduleSlotRow(
                            item: item,
                            onBook: { openBookClient(item) },
                            onOpenActions: { openBookingActions(item) }
                        )
                        .accessibilityAction(named: Text("schedule.action.deleteSlot")) {
                            requestDelete(item)
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

    private func openBookClient(_ item: SlotItem) {
        withoutPresentationAnimation {
            bookClient = viewModel.makeBookClientViewModel(slotId: item.id)
        }
    }

    private func closeBookClient() {
        withoutPresentationAnimation {
            bookClient = nil
        }
    }

    private func openBookingActions(_ item: SlotItem) {
        withoutPresentationAnimation {
            bookingActions = viewModel.makeBookingActionsViewModel(slotId: item.id)
        }
    }

    private func closeBookingActions() {
        withoutPresentationAnimation {
            bookingActions = nil
        }
    }

    private func openPendingCard() {
        openCardClientId = pendingCardClientId
        pendingCardClientId = nil
    }

    private func requestDelete(_ item: SlotItem) {
        guard item.booking != nil else {
            delete(item)
            return
        }

        pendingDelete = item
        isConfirmingDelete = true
    }

    private func delete(_ item: SlotItem) {
        viewModel.delete(id: item.id)
    }
}

#if DEBUG
#Preview {
    ScheduleView(
        viewModel: ScheduleViewModel(
            slotRepository: FakeSlotRepository(slots: SchedulePreviewData.slots),
            clientRepository: FakeClientRepository(clients: ClientsPreviewData.clients),
            serviceRepository: FakeServiceRepository(services: ServicesPreviewData.services)
        )
    )
}
#endif
