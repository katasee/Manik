import SwiftUI

struct MyBookingsView: View {
    @State private var viewModel: MyBookingsViewModel
    @State private var cancelContext: CancelBookingContext?

    init(viewModel: MyBookingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(titleKey: "myBookings.title")

            ScrollView {
                VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.sectionSpacing) {
                    ForEach(viewModel.sections) { section in
                        MyBookingSectionView(section: section, onCancel: showCancel)
                    }
                }
                .padding(.horizontal, MyBookingsMetrics.Spacing.horizontalPadding)
                .padding(.top, MyBookingsMetrics.Spacing.listTopPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .overlay {
            ListStatusOverlay(
                hasLoaded: viewModel.hasLoaded,
                isEmpty: viewModel.sections.isEmpty,
                titleKey: "myBookings.empty.title",
                messageKey: "myBookings.empty.message"
            )
        }
        .fullScreenCover(item: $cancelContext) { context in
            CancelBookingPopup(
                viewModel: viewModel.makeCancelViewModel(context: context),
                onDismiss: dismissCancel
            )
            .presentationBackground(.clear)
        }
        .task {
            await viewModel.observeBlocks()
        }
        .task {
            await viewModel.observeServices()
        }
        .task {
            await viewModel.refreshSections()
        }
    }

    private func showCancel(_ context: CancelBookingContext) {
        withoutPresentationAnimation {
            cancelContext = context
        }
    }

    private func dismissCancel() {
        withoutPresentationAnimation {
            cancelContext = nil
        }
    }
}

#if DEBUG
#Preview("З записами") {
    MyBookingsView(
        viewModel: MyBookingsViewModel(
            clientId: MyBookingsPreviewData.clientId,
            blockRepository: FakeBlockRepository(blocks: MyBookingsPreviewData.blocks),
            serviceRepository: FakeServiceRepository(services: MyBookingsPreviewData.services)
        )
    )
}

#Preview("Порожньо") {
    MyBookingsView(
        viewModel: MyBookingsViewModel(
            clientId: MyBookingsPreviewData.clientId,
            blockRepository: FakeBlockRepository(blocks: []),
            serviceRepository: FakeServiceRepository(services: MyBookingsPreviewData.services)
        )
    )
}

#Preview("Тільки майбутні") {
    MyBookingsView(
        viewModel: MyBookingsViewModel(
            clientId: MyBookingsPreviewData.clientId,
            blockRepository: FakeBlockRepository(blocks: MyBookingsPreviewData.upcomingOnly),
            serviceRepository: FakeServiceRepository(services: MyBookingsPreviewData.services)
        )
    )
}
#endif
