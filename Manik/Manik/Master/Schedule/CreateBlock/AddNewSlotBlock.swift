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
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .ignoresSafeArea()

            card
                .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.CreatePopup.rowSpacing) {
            fieldRow("schedule.createSlot.dateLabel") {
                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                    .labelsHidden()
            }

            fieldRow("schedule.createSlot.startLabel") {
                DatePicker("", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }

            fieldRow("schedule.createSlot.endLabel") {
                DatePicker("", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }

            Color.surface
                .frame(height: 1)

            servicesHeader

            ServicesChecklist(
                services: viewModel.services,
                isSelected: viewModel.isSelected,
                onToggle: viewModel.toggleSelection
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.elmsSans(.regular, 13))
                    .foregroundStyle(.red)
            }

            buttons
        }
        .padding(ScheduleMetrics.CreatePopup.cardPadding)
        .background(Color.background, in: .rect(cornerRadius: ScheduleMetrics.CreatePopup.cornerRadius))
    }

    private func fieldRow(_ labelKey: LocalizedStringKey, @ViewBuilder control: () -> some View) -> some View {
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

    private var buttons: some View {
        HStack(spacing: 12) {
            Button("schedule.createSlot.cancel", action: onDismiss)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.textSecondary)
                .frame(minHeight: 44)

            Spacer()

            Button(action: handleCreate) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("schedule.createSlot.create")
                        .font(.elmsSans(.bold, 15))
                }
            }
            .foregroundStyle(.white)
            .frame(minHeight: 44)
            .padding(.horizontal, 20)
            .background(Color.ink, in: .capsule)
            .disabled(viewModel.isSaving || !viewModel.canSubmit)
            .opacity(viewModel.isSaving || !viewModel.canSubmit ? 0.4 : 1)
        }
        .buttonStyle(.plain)
    }

    private func handleCreate() {
        Task {
            if await viewModel.submit() {
                onDismiss()
            }
        }
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
