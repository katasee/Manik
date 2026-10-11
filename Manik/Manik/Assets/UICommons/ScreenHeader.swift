import SwiftUI

private enum ScreenHeaderLayout {
    static let horizontalPadding: CGFloat = 16
    static let title: CGFloat = 17
    static let barHeight: CGFloat = 44
}

struct ScreenHeader<Trailing: View>: View {
    let titleKey: LocalizedStringKey?
    let onBack: () -> Void
    @ViewBuilder let trailing: Trailing

    init(
        titleKey: LocalizedStringKey? = nil,
        onBack: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.titleKey = titleKey
        self.onBack = onBack
        self.trailing = trailing()
    }

    var body: some View {
        ZStack {
            if let titleKey {
                Text(titleKey)
                    .font(.elmsSans(.semiBold, ScreenHeaderLayout.title))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .padding(.horizontal, ScreenHeaderLayout.barHeight)
                    .accessibilityAddTraits(.isHeader)
            }

            HStack {
                RoundIconButton(
                    systemImage: "chevron.left",
                    size: .small,
                    accessibilityLabel: "common.action.back",
                    action: onBack
                )

                Spacer()

                trailing
            }
        }
        .frame(minHeight: ScreenHeaderLayout.barHeight)
        .padding(.horizontal, ScreenHeaderLayout.horizontalPadding)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(titleKey: LocalizedStringKey? = nil, onBack: @escaping () -> Void) {
        self.init(titleKey: titleKey, onBack: onBack) {
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ScreenHeader(titleKey: "services.title", onBack: {})

        ScreenHeader(onBack: {}) {
            RoundIconButton(
                systemImage: "pencil",
                size: .small,
                accessibilityLabel: "common.action.back",
                action: {}
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.background)
}
