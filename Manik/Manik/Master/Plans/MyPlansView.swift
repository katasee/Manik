import SwiftUI

struct MyPlansView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: MyPlansViewModel
    @State private var formMode: PlanFormMode?
    @State private var openRowId: String?

    init(viewModel: MyPlansViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(onBack: goBack) {
                RoundIconButton(
                    systemImage: "plus",
                    size: .small,
                    accessibilityLabel: "plans.action.add",
                    action: addTemplate
                )
            }

            LargeTitleHeader(titleKey: "plans.title", subtitle: String(localized: "plans.subtitle"))

            sectionHeader
            list
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.observeTemplates()
        }
        .alert(
            viewModel.failure?.titleKey ?? "",
            isPresented: $viewModel.hasFailure
        ) {
            Button("common.action.ok", role: .cancel) {}
        }
        .fullScreenCover(item: $formMode) { mode in
            PlanFormPopup(
                viewModel: PlanFormViewModel(mode: mode),
                onSave: viewModel.save,
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    @ViewBuilder
    private var sectionHeader: some View {
        if viewModel.templates.isEmpty == false {
            SectionLabel(titleKey: "plans.section.all", count: viewModel.templates.count)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, PlansMetrics.Spacing.horizontalPadding)
                .padding(.top, PlansMetrics.Spacing.sectionTopPadding)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: PlansMetrics.Spacing.rowSpacing) {
                ForEach(viewModel.templates) { template in
                    SwipeToDelete(
                        id: template.id ?? "",
                        openId: $openRowId,
                        cornerRadius: PlansMetrics.Size.rowCornerRadius,
                        onDelete: { viewModel.delete(template) }
                    ) {
                        PlanRow(
                            template: template,
                            onToggleActive: { viewModel.toggleActive(template) }
                        )
                        .onTapGesture { editTemplate(template) }
                        .accessibilityAddTraits(.isButton)
                    }
                }
            }
            .padding(.horizontal, PlansMetrics.Spacing.horizontalPadding)
            .padding(.top, PlansMetrics.Spacing.listTopPadding)
            .padding(.bottom, PlansMetrics.Spacing.listBottomPadding)
        }
        .overlay {
            ListStatusOverlay(
                hasLoaded: viewModel.hasLoaded,
                isEmpty: viewModel.templates.isEmpty,
                titleKey: emptyTitleKey,
                messageKey: emptyMessageKey
            )
        }
    }

    private var emptyTitleKey: LocalizedStringKey {
        viewModel.hasFailed ? "plans.loadFailed.title" : "plans.empty.title"
    }

    private var emptyMessageKey: LocalizedStringKey {
        viewModel.hasFailed ? "plans.loadFailed.message" : "plans.empty.message"
    }

    private func addTemplate() {
        withoutPresentationAnimation {
            formMode = .add
        }
    }

    private func editTemplate(_ template: EventTemplate) {
        guard openRowId == nil else {
            openRowId = nil
            return
        }

        withoutPresentationAnimation {
            formMode = .edit(template)
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
