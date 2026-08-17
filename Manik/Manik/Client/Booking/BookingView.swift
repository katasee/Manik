import SwiftUI

struct BookingView: View {
    @State private var viewModel: BookingViewModel
    @State private var confirmContext: BookingConfirmContext?

    let clientName: String
    let bottomClearance: CGFloat
    let onBooked: () -> Void

    init(
        viewModel: BookingViewModel,
        clientName: String,
        bottomClearance: CGFloat,
        onBooked: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.clientName = clientName
        self.bottomClearance = bottomClearance
        self.onBooked = onBooked
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        BookingHeader(
                            clientName: clientName,
                            nearestSlot: viewModel.nearestSlot,
                            topInset: proxy.safeAreaInsets.top
                        )

                        sectionHeader
                        list
                    }
                }
                .scrollIndicators(.hidden)
                .ignoresSafeArea(.container, edges: .top)
                .overlay {
                    ListStatusOverlay(
                        hasLoaded: viewModel.hasLoaded,
                        isEmpty: viewModel.offers.isEmpty,
                        titleKey: "booking.empty.title",
                        messageKey: "booking.empty.message"
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ServiceOffer.self) { offer in
                BookingDatesView(
                    viewModel: viewModel.makeDatesViewModel(for: offer),
                    bottomClearance: bottomClearance,
                    onBooked: onBooked
                )
            }
            .fullScreenCover(item: $confirmContext) { context in
                BookingConfirmPopup(
                    viewModel: viewModel.makeConfirmViewModel(context: context),
                    onDismiss: dismissConfirm,
                    onFinish: finishConfirm
                )
                .presentationBackground(.clear)
            }
        }
        .task {
            await viewModel.observeBlocks()
        }
        .task {
            await viewModel.observeServices()
        }
        .task {
            await viewModel.refreshAvailability()
        }
    }

    @ViewBuilder
    private var sectionHeader: some View {
        if viewModel.offers.isEmpty == false {
            HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
                Text("booking.section.services")
                    .font(.elmsSans(.bold, 20))
                    .foregroundStyle(Color.ink)

                Spacer(minLength: 0)

                Text(viewModel.offers.count.formatted())
                    .font(.elmsSans(.medium, 14))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
            .padding(.top, BookingMetrics.Spacing.sectionTopPadding)
        }
    }
    
    private var list: some View {
        LazyVStack(spacing: BookingMetrics.Spacing.listSpacing) {
            ForEach(viewModel.offers) { offer in
                ServiceOfferCard(
                    offer: offer,
                    onSelect: { presentConfirm(offer: offer, slot: $0) }
                )
            }
        }
        .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
        .padding(.top, BookingMetrics.Spacing.listTopPadding)
        .padding(.bottom, bottomClearance)
    }

    private func presentConfirm(offer: ServiceOffer, slot: BookingSlot) {
        withoutPresentationAnimation {
            confirmContext = BookingConfirmContext(service: offer.service, slot: slot)
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
#Preview("З пропозиціями") {
    BookingView(
        viewModel: BookingViewModel(
            clientId: BookingPreviewData.clientId,
            blockRepository: FakeBlockRepository(blocks: BookingPreviewData.blocks),
            serviceRepository: FakeServiceRepository(services: BookingPreviewData.services)
        ),
        clientName: "Олена",
        bottomClearance: 0,
        onBooked: {}
    )
}

#Preview("Порожньо") {
    BookingView(
        viewModel: BookingViewModel(
            clientId: BookingPreviewData.clientId,
            blockRepository: FakeBlockRepository(blocks: []),
            serviceRepository: FakeServiceRepository(services: BookingPreviewData.services)
        ),
        clientName: "Олена",
        bottomClearance: 0,
        onBooked: {}
    )
}
#endif
