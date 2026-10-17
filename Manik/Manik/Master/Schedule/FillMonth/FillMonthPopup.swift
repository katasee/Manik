import SwiftUI

struct FillMonthPopup: View {
    let viewModel: FillMonthViewModel
    let onDismiss: () -> Void

    @State private var contentHeight: CGFloat?

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
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(-ScheduleMetrics.Spacing.scrollShadowInset)

            actions(dismiss: dismiss)
        }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            Text("schedule.fill.title")
                .font(.elmsSans(.bold, ScheduleMetrics.Size.fillTitle))
                .foregroundStyle(Color.ink)
                .accessibilityAddTraits(.isHeader)

            MonthHeader(
                title: viewModel.monthTitle,
                canGoBack: viewModel.canGoBack,
                canGoForward: true,
                onPrevious: viewModel.showPreviousMonth,
                onNext: viewModel.showNextMonth
            )

            FillMonthCalendar(viewModel: viewModel)

            FillMonthHours(viewModel: viewModel)
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "schedule.fill.add \(viewModel.newSlotCount)",
                role: .primary,
                isEnabled: viewModel.newSlotCount > 0,
                action: { add(then: dismiss) }
            )
        }
    }

    private func add(then dismiss: () -> Void) {
        viewModel.add()
        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            FillMonthPopup(viewModel: SchedulePreviewData.fillMonth, onDismiss: {})
        }
}
#endif
