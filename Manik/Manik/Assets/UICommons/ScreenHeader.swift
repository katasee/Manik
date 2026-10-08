import SwiftUI

struct ScreenHeader: View {
    let titleKey: LocalizedStringKey
    let onBack: () -> Void

    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let title: CGFloat = 17
        static let barHeight: CGFloat = 44
    }

    var body: some View {
        ZStack {
            Text(titleKey)
                .font(.elmsSans(.semiBold, Layout.title))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .padding(.horizontal, Layout.barHeight)
                .accessibilityAddTraits(.isHeader)

            HStack {
                RoundIconButton(
                    systemImage: "chevron.left",
                    size: .small,
                    accessibilityLabel: "common.action.back",
                    action: onBack
                )

                Spacer()
            }
        }
        .frame(minHeight: Layout.barHeight)
        .padding(.horizontal, Layout.horizontalPadding)
    }
}

#Preview {
    ScreenHeader(titleKey: "services.title", onBack: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
}
