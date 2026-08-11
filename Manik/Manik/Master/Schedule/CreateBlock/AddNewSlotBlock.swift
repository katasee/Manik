import SwiftUI

struct AddNewSlotBlock: View {
    @State private var viewModel: CreateBlockViewModel
    let onDismiss: () -> Void

    init(
        date: Date,
        startHour: Int,
        services: [Service],
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: CreateBlockViewModel(
            date: date,
            startHour: startHour,
            services: services,
            blockRepository: blockRepository
        ))
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "schedule.createSlot.cancel",
            onDismiss: onDismiss
        ) { dismiss in
            dateField
            timeField("schedule.createSlot.startLabel", text: $viewModel.startTimeText)
            timeField("schedule.createSlot.endLabel", text: $viewModel.endTimeText)

            divider

            servicesHeader
            servicesChecklist

            errorText

            actions(dismiss: dismiss)
        }
    }

    private var dateField: some View {
        fieldRow("schedule.createSlot.dateLabel") {
            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                .labelsHidden()
        }
    }

    private func timeField(
        _ labelKey: LocalizedStringKey,
        text: Binding<String>
    ) -> some View {
        fieldRow(labelKey) {
            TextField("", text: text)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
        }
    }

    private var divider: some View {
        Color.surface
            .frame(height: 1)
    }

    private var servicesChecklist: some View {
        ServicesChecklist(
            services: viewModel.services,
            isSelected: viewModel.isSelected,
            onToggle: viewModel.toggleSelection
        )
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "schedule.createSlot.cancel", action: dismiss)

            Spacer()

            PopupPrimaryButton(
                titleKey: "schedule.createSlot.create",
                color: .ink,
                isLoading: viewModel.isSaving,
                isEnabled: viewModel.canSubmit,
                action: { create(then: dismiss) }
            )
        }
    }

    private func create(then dismiss: @escaping () -> Void) {
        Task { @MainActor in
            if await viewModel.submit() {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var errorText: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
        }
    }

    private func fieldRow(
        _ labelKey: LocalizedStringKey,
        @ViewBuilder control: () -> some View
    ) -> some View {
        HStack {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)

            Spacer()

            control()
        }
    }

    private var servicesHeader: some View {
        Text("schedule.createSlot.servicesHeader")
            .font(.elmsSans(.bold, 16))
            .foregroundStyle(Color.ink)
    }
}

#Preview {
    Color.background
        .overlay {
            AddNewSlotBlock(
                date: .now,
                startHour: 17,
                services: SchedulePreviewData.services,
                blockRepository: FakeBlockRepository(),
                onDismiss: {}
            )
        }
}
