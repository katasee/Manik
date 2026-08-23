import SwiftUI

struct RequestsView: View {
    @State private var viewModel: RequestsViewModel

    init(viewModel: RequestsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(titleKey: "requests.title")

            ScrollView {
                VStack(spacing: RequestsMetrics.Spacing.listSpacing) {
                    ForEach(viewModel.requests) { request in
                        RequestCard(
                            request: request,
                            isBusy: viewModel.isBusy,
                            runningAction: viewModel.runningAction(on: request.id),
                            perform: { await viewModel.perform($0, on: request.id) }
                        )
                    }
                }
                .padding(.horizontal, RequestsMetrics.Spacing.horizontalPadding)
                .padding(.top, RequestsMetrics.Spacing.listTopPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .overlay {
            ListStatusOverlay(
                hasLoaded: viewModel.hasLoaded,
                isEmpty: viewModel.requests.isEmpty,
                titleKey: "requests.empty.title",
                messageKey: "requests.empty.message"
            )
        }
        .alert("requests.error.generic", isPresented: $viewModel.hasFailed) {
            Button("common.action.ok", role: .cancel) {}
        }
        .task {
            await viewModel.observeBlocks()
        }
        .task {
            await viewModel.refreshRequests()
        }
    }
}

#if DEBUG
#Preview("Заявки") {
    RequestsView(
        viewModel: RequestsViewModel(
            blockRepository: FakeBlockRepository(blocks: RequestsPreviewData.blocks),
            userRepository: FakeUserRepository(profiles: RequestsPreviewData.profiles)
        )
    )
}

#Preview("Порожньо") {
    RequestsView(
        viewModel: RequestsViewModel(
            blockRepository: FakeBlockRepository(blocks: []),
            userRepository: FakeUserRepository(profiles: RequestsPreviewData.profiles)
        )
    )
}

#Preview("Профіль не читається") {
    RequestsView(
        viewModel: RequestsViewModel(
            blockRepository: FakeBlockRepository(blocks: RequestsPreviewData.unreadableClient),
            userRepository: FakeUserRepository(profiles: RequestsPreviewData.profiles)
        )
    )
}

#Preview("Помилка дії") {
    RequestsView(
        viewModel: RequestsViewModel(
            blockRepository: FailingBlockRepository(blocks: RequestsPreviewData.blocks),
            userRepository: FakeUserRepository(profiles: RequestsPreviewData.profiles)
        )
    )
}
#endif
