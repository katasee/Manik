import SwiftUI

struct MyServicesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: MyServicesViewModel
    @State private var formMode: ServiceFormMode?
    @State private var openRowId: String?

    init(viewModel: MyServicesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            intro
            sectionHeader
            list
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.observeServices()
        }
        .alert(
            viewModel.failure?.titleKey ?? "",
            isPresented: $viewModel.hasFailure
        ) {
            Button("common.action.ok", role: .cancel) {}
        }
        .fullScreenCover(item: $formMode) { mode in
            ServiceFormPopup(
                viewModel: viewModel.makeFormViewModel(for: mode),
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    private var header: some View {
        ZStack {
            title

            HStack {
                backButton
                Spacer()
            }
        }
        .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
    }

    private var backButton: some View {
        Button("common.action.back", systemImage: "chevron.left", action: goBack)
            .labelStyle(.iconOnly)
            .font(.elmsSans(.regular, ServicesMetrics.Size.backIcon))
            .foregroundStyle(Color.ink)
            .frame(
                minWidth: ServicesMetrics.Size.backTapTarget,
                minHeight: ServicesMetrics.Size.backTapTarget,
                alignment: .leading
            )
            .contentShape(.rect)
    }

    private var title: some View {
        Text("services.title")
            .font(.elmsSans(.bold, 22))
            .foregroundStyle(Color.ink)
    }

    private var intro: some View {
        HStack(spacing: ServicesMetrics.Spacing.rowContentSpacing) {
            subtitle

            Spacer(minLength: 0)

            addButton
        }
        .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
        .padding(.top, ServicesMetrics.Spacing.introTopPadding)
    }

    private var subtitle: some View {
        Text("services.subtitle")
            .font(.elmsSans(.regular, 15))
            .foregroundStyle(Color.textSecondary)
    }

    private var addButton: some View {
        Button("services.action.add", systemImage: "plus", action: addService)
            .labelStyle(.iconOnly)
            .font(.elmsSans(.bold, ServicesMetrics.Size.addIcon))
            .foregroundStyle(Color.background)
            .frame(
                width: ServicesMetrics.Size.addButton,
                height: ServicesMetrics.Size.addButton
            )
            .background(Color.ink, in: .circle)
            .contentShape(.circle)
    }

    @ViewBuilder
    private var sectionHeader: some View {
        if viewModel.services.isEmpty == false {
            HStack(spacing: ServicesMetrics.Spacing.sectionSpacing) {
                Text("services.section.all")
                    .font(.elmsSans(.medium, 13))
                    .textCase(.uppercase)
                    .tracking(ServicesMetrics.Tracking.sectionLabel)
                    .foregroundStyle(Color.textSecondary)

                Text(verbatim: "·")
                    .font(.elmsSans(.medium, 13))
                    .foregroundStyle(Color.textSecondary)

                Text(viewModel.services.count.formatted())
                    .font(.elmsSans(.bold, 13))
                    .foregroundStyle(Color.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
            .padding(.top, ServicesMetrics.Spacing.sectionTopPadding)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
                ForEach(viewModel.services) { service in
                    SwipeToDelete(
                        id: service.id ?? "",
                        openId: $openRowId,
                        cornerRadius: ServicesMetrics.Size.rowCornerRadius,
                        onDelete: { delete(service) }
                    ) {
                        ServiceRow(
                            service: service,
                            onToggleActive: { toggleActive(service) }
                        )
                        .onTapGesture { editService(service) }
                    }
                }
            }
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
            .padding(.top, ServicesMetrics.Spacing.listTopPadding)
        }
        .overlay { statusOverlay }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        if viewModel.hasLoaded == false {
            ProgressView()
                .tint(Color.ink)
        } else if viewModel.services.isEmpty {
            ContentUnavailableView {
                Text("services.empty.title")
                    .font(.elmsSans(.bold, 18))
                    .foregroundStyle(Color.ink)
            } description: {
                Text("services.empty.message")
                    .font(.elmsSans(.regular, 14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private func delete(_ service: Service) {
        Task {
            await viewModel.delete(service)
        }
    }

    private func toggleActive(_ service: Service) {
        Task {
            await viewModel.toggleActive(service)
        }
    }

    private func addService() {
        withoutPresentationAnimation {
            formMode = .add
        }
    }

    private func editService(_ service: Service) {
        guard openRowId == nil else {
            openRowId = nil
            return
        }

        withoutPresentationAnimation {
            formMode = .edit(service)
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            formMode = nil
        }
    }

    private func goBack() {
        dismiss()
    }
}

#if DEBUG
#Preview("З послугами") {
    NavigationStack {
        MyServicesView(
            viewModel: MyServicesViewModel(
                serviceRepository: FakeServiceRepository(services: ServicesPreviewData.services)
            )
        )
    }
}

#Preview("Порожній список") {
    NavigationStack {
        MyServicesView(
            viewModel: MyServicesViewModel(serviceRepository: FakeServiceRepository(services: []))
        )
    }
}
#endif
