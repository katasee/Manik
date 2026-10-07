import SwiftUI

private enum TimeField {
    case start
    case end
}

struct AddNewSlotBlock: View {
    @State private var viewModel: CreateBlockViewModel
    @State private var expandedField: TimeField?
    let onDismiss: () -> Void

    private static let startHours = WorkHours.working.lowerBound...(WorkHours.working.upperBound - 1)
    private static let endHours = WorkHours.working.lowerBound...WorkHours.working.upperBound

    init(
        context: CreateBlockContext,
        blockRepository: BlockRepository = FirestoreBlockRepository(),
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: CreateBlockViewModel(
            date: context.date,
            startHour: context.startHour,
            services: context.services,
            blocks: context.blocks,
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

            timeRow(
                .start,
                labelKey: "schedule.createSlot.startLabel",
                time: viewModel.start
            )
            if expandedField == .start {
                TimeWheel(time: $viewModel.start, hours: Self.startHours)
            }

            timeRow(
                .end,
                labelKey: "schedule.createSlot.endLabel",
                time: viewModel.end
            )
            if expandedField == .end {
                TimeWheel(time: $viewModel.end, hours: Self.endHours)
            }

            divider

            servicesHeader
            servicesChecklist

            messageText

            actions(dismiss: dismiss)
        }
        .onChange(of: viewModel.start) { oldValue, newValue in
            viewModel.startDidChange(from: oldValue, to: newValue)
        }
    }

    private var dateField: some View {
        fieldRow("schedule.createSlot.dateLabel") {
            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                .labelsHidden()
        }
    }

    private func timeRow(
        _ field: TimeField,
        labelKey: LocalizedStringKey,
        time: ClockTime
    ) -> some View {
        fieldRow(labelKey) {
            Button {
                toggle(field)
            } label: {
                Text(DateFormat.displayTime(DateFormat.storageTime(minutesOfDay: time.minutesOfDay)))
                    .font(.elmsSans(.semiBold, 15))
                    .foregroundStyle(expandedField == field ? Color.accentColor : Color.ink)
                    .padding(.horizontal, ScheduleMetrics.CreatePopup.timeHorizontalPadding)
                    .padding(.vertical, ScheduleMetrics.CreatePopup.timeVerticalPadding)
                    .raisedSurface(.capsule)
            }
            .buttonStyle(.plain)
        }
    }

    private func toggle(_ field: TimeField) {
        withAnimation(.snappy) {
            expandedField = expandedField == field ? nil : field
        }
    }

    private var divider: some View {
        Color.hairline
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

            CapsuleButton(
                titleKey: "schedule.createSlot.create",
                role: .primary,
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
    private var messageText: some View {
        if let errorMessage = viewModel.errorMessage {
            message(Text(errorMessage))
        } else if let issue = viewModel.timeIssue {
            message(Text(issue.messageKey))
        }
    }

    private func message(_ text: Text) -> some View {
        text
            .font(.elmsSans(.regular, 13))
            .foregroundStyle(Color.destructive)
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

#if DEBUG
#Preview("Free hour") {
    Color.background
        .overlay {
            AddNewSlotBlock(
                context: CreateBlockContext(
                    date: .now,
                    startHour: 17,
                    services: SchedulePreviewData.services,
                    blocks: SchedulePreviewData.blocks
                ),
                blockRepository: FakeBlockRepository(),
                onDismiss: {}
            )
        }
}

#Preview("Taken hour") {
    Color.background
        .overlay {
            AddNewSlotBlock(
                context: CreateBlockContext(
                    date: .now,
                    startHour: 10,
                    services: SchedulePreviewData.services,
                    blocks: SchedulePreviewData.blocks
                ),
                blockRepository: FakeBlockRepository(),
                onDismiss: {}
            )
        }
}

#Preview("Next block off-grid") {
    let today = DateFormat.date.string(from: .now)
    let blocks = [
        Block(
            id: "short",
            date: today,
            startTime: "10:00",
            endTime: "10:15",
            offeredServiceIds: [],
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        ),
        Block(
            id: "off-grid",
            date: today,
            startTime: "10:50",
            endTime: "12:00",
            offeredServiceIds: [],
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )
    ]

    Color.background
        .overlay {
            AddNewSlotBlock(
                context: CreateBlockContext(
                    date: .now,
                    startHour: 10,
                    services: SchedulePreviewData.services,
                    blocks: blocks
                ),
                blockRepository: FakeBlockRepository(),
                onDismiss: {}
            )
        }
}
#endif
