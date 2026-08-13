import SwiftUI

struct MonthHeader: View {
    let title: String
    let canGoBack: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
            previousArrow
            monthTitle
            nextArrow
        }
    }

    private var previousArrow: some View {
        arrow(
            systemName: "chevron.left",
            labelKey: "booking.calendar.previousMonth",
            action: onPrevious
        )
        .disabled(canGoBack == false)
        .opacity(canGoBack ? 1 : BookingMetrics.Opacity.outsideMonth)
    }

    private var nextArrow: some View {
        arrow(
            systemName: "chevron.right",
            labelKey: "booking.calendar.nextMonth",
            action: onNext
        )
    }

    private var monthTitle: some View {
        Text(verbatim: title)
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity)
    }

    private func arrow(
        systemName: String,
        labelKey: LocalizedStringKey,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(labelKey, systemImage: systemName)
                .labelStyle(.iconOnly)
                .font(.elmsSans(.semiBold, 14))
                .foregroundStyle(Color.ink)
                .frame(
                    width: BookingMetrics.Size.monthArrow,
                    height: BookingMetrics.Size.monthArrow
                )
                .background {
                    Circle()
                        .fill(Color.surface)
                        .frame(
                            width: BookingMetrics.Size.monthArrowCircle,
                            height: BookingMetrics.Size.monthArrowCircle
                        )
                }
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        MonthHeader(
            title: "Серпень 2026",
            canGoBack: false,
            onPrevious: {},
            onNext: {}
        )

        MonthHeader(
            title: "Вересень 2026",
            canGoBack: true,
            onPrevious: {},
            onNext: {}
        )
    }
    .padding()
    .background(Color.background)
}
#endif
