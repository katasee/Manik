import SwiftUI

struct MonthHeader: View {
    let title: String
    let canGoBack: Bool
    let canGoForward: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    private enum Layout {
        static let spacing: CGFloat = 8
        static let title: CGFloat = 17
    }

    var body: some View {
        HStack(spacing: Layout.spacing) {
            arrow(
                systemName: "chevron.left",
                labelKey: "booking.calendar.previousMonth",
                isEnabled: canGoBack,
                action: onPrevious
            )

            Text(verbatim: title)
                .font(.elmsSans(.semiBold, Layout.title))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity)

            arrow(
                systemName: "chevron.right",
                labelKey: "booking.calendar.nextMonth",
                isEnabled: canGoForward,
                action: onNext
            )
        }
    }

    private func arrow(
        systemName: String,
        labelKey: LocalizedStringKey,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        RoundIconButton(
            systemImage: systemName,
            size: .small,
            accessibilityLabel: labelKey,
            action: action
        )
        .disabled(isEnabled == false)
    }
}

#Preview {
    VStack(spacing: 24) {
        MonthHeader(
            title: "Серпень 2026",
            canGoBack: false,
            canGoForward: true,
            onPrevious: {},
            onNext: {}
        )

        MonthHeader(
            title: "Вересень 2026",
            canGoBack: true,
            canGoForward: false,
            onPrevious: {},
            onNext: {}
        )
    }
    .padding()
    .background(Color.background)
}
