import SwiftUI

struct MonthHeader: View {
    let title: String
    let canGoBack: Bool
    let canGoForward: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    private enum Layout {
        static let spacing: CGFloat = 8
        static let tapTarget: CGFloat = 44
        static let circle: CGFloat = 32
        static let title: CGFloat = 18
        static let icon: CGFloat = 14
        static let disabled: Double = 0.3
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
                .font(.elmsSans(.bold, Layout.title))
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
        Button(action: action) {
            Label(labelKey, systemImage: systemName)
                .labelStyle(.iconOnly)
                .font(.elmsSans(.semiBold, Layout.icon))
                .foregroundStyle(Color.ink)
                .frame(width: Layout.tapTarget, height: Layout.tapTarget)
                .background {
                    Circle()
                        .fill(Color.fieldBackground)
                        .frame(width: Layout.circle, height: Layout.circle)
                        .cardShadow()
                }
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .opacity(isEnabled ? 1 : Layout.disabled)
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
