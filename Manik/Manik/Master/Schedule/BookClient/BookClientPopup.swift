import SwiftUI

struct BookClientPopup: View {
    @Bindable var viewModel: BookClientViewModel
    let onDismiss: () -> Void

    @State private var contentHeight: CGFloat?
    @State private var newClientForm: ClientFormViewModel?

    var body: some View {
        PopupContainer(dismissLabel: "common.action.cancel", onDismiss: onDismiss) { dismiss in
            ScrollView {
                sections
                    .padding(ScheduleMetrics.Spacing.scrollShadowInset)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        contentHeight = height
                    }
            }
            .frame(maxHeight: contentHeight)
            .opacity(contentHeight == nil ? 0 : 1)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(-ScheduleMetrics.Spacing.scrollShadowInset)

            actions(dismiss: dismiss)
        }
        .fullScreenCover(item: $newClientForm) { form in
            @Bindable var form = form

            ClientFormPopup(
                fields: $form.fields,
                errors: form.errors,
                isSaving: form.isSaving,
                onSubmit: form.submit,
                onDismiss: closeNewClientForm
            )
            .onChange(of: form.fields) {
                form.applyMasks()
            }
            .presentationBackground(.clear)
        }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.bookTitleSpacing) {
                Text("schedule.book.title")
                    .font(.elmsSans(.bold, ScheduleMetrics.Size.bookTitle))
                    .foregroundStyle(Color.ink)
                    .accessibilityAddTraits(.isHeader)

                Text(verbatim: viewModel.subtitle)
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.bookSubtitle))
                    .foregroundStyle(Color.textSecondary)
            }

            SearchField(
                text: $viewModel.searchText,
                placeholderKey: "schedule.book.search.placeholder",
                focusesOnAppear: true
            )

            if viewModel.options.isEmpty == false {
                VStack(spacing: ScheduleMetrics.Spacing.bookOptionSpacing) {
                    ForEach(viewModel.options) { option in
                        BookClientRow(option: option) {
                            viewModel.toggleClient(option.id)
                        }
                    }
                }
            }

            CapsuleButton(
                titleKey: "schedule.book.newClient",
                role: .secondary,
                systemImage: "plus",
                fillsWidth: true,
                action: openNewClientForm
            )

            if viewModel.services.isEmpty == false {
                SectionLabel(titleKey: "schedule.book.service")

                BookServiceChips(chips: viewModel.services, onToggle: viewModel.toggleService)
            }
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "schedule.book.submit",
                role: .primary,
                isEnabled: viewModel.canBook,
                action: { book(then: dismiss) }
            )
        }
    }

    private func book(then dismiss: () -> Void) {
        viewModel.book()
        dismiss()
    }

    private func openNewClientForm() {
        withoutPresentationAnimation {
            newClientForm = viewModel.makeNewClientForm()
        }
    }

    private func closeNewClientForm() {
        if let client = newClientForm?.savedClient {
            viewModel.select(newClient: client)
        }

        withoutPresentationAnimation {
            newClientForm = nil
        }
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            BookClientPopup(viewModel: SchedulePreviewData.bookClient, onDismiss: {})
        }
}
#endif
