import SwiftUI

struct BookingView: View {
    @State private var viewModel: BookingViewModel

    let clientName: String
    let bottomClearance: CGFloat

    init(
        viewModel: BookingViewModel,
        clientName: String,
        bottomClearance: CGFloat
    ) {
        _viewModel = State(initialValue: viewModel)
        self.clientName = clientName
        self.bottomClearance = bottomClearance
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    BookingHeader(
                        clientName: clientName,
                        nearestSlot: viewModel.nearestSlot
                    )

                    sectionHeader
                    list
                }
            }
            .scrollIndicators(.hidden)
            .overlay { statusOverlay }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ServiceOffer.self) { offer in
                BookingDatesView(
                    viewModel: BookingDatesViewModel(offer: offer),
                    bottomClearance: bottomClearance
                )
            }
            .navigationDestination(for: BookingSlot.self) { slot in
                BookingConfirmView(slot: slot)
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
                ServiceOfferCard(offer: offer)
            }
        }
        .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
        .padding(.top, BookingMetrics.Spacing.listTopPadding)
        .padding(.bottom, bottomClearance)
    }
    
    @ViewBuilder
    private var statusOverlay: some View {
        if viewModel.hasLoaded == false {
            ProgressView()
                .tint(Color.ink)
        } else if viewModel.offers.isEmpty {
            ContentUnavailableView {
                Text("booking.empty.title")
                    .font(.elmsSans(.bold, 18))
                    .foregroundStyle(Color.ink)
            } description: {
                Text("booking.empty.message")
                    .font(.elmsSans(.regular, 14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

#if DEBUG
#Preview("З пропозиціями") {
    BookingView(
        viewModel: BookingViewModel(
            blockRepository: FakeBlockRepository(blocks: BookingPreviewData.blocks),
            serviceRepository: FakeServiceRepository(services: BookingPreviewData.services)
        ),
        clientName: "Олена",
        bottomClearance: 0
    )
}

#Preview("Порожньо") {
    BookingView(
        viewModel: BookingViewModel(
            blockRepository: FakeBlockRepository(blocks: []),
            serviceRepository: FakeServiceRepository(services: BookingPreviewData.services)
        ),
        clientName: "Олена",
        bottomClearance: 0
    )
}
#endif
