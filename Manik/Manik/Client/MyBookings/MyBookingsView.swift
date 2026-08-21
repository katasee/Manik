import SwiftUI

struct MyBookingsView: View {
    @State private var viewModel: MyBookingsViewModel

    init(viewModel: MyBookingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(titleKey: "myBookings.title")

            ScrollView {
                VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.sectionSpacing) {
                    ForEach(viewModel.sections) { section in
                        MyBookingSectionView(section: section)
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
