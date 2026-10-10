import SwiftUI

private enum LargeTitleHeaderLayout {
    static let spacing: CGFloat = 6
    static let titleRowSpacing: CGFloat = 12
    static let horizontalPadding: CGFloat = 20
    static let topPadding: CGFloat = 12
    static let title: CGFloat = 32
    static let titleTracking: CGFloat = -0.6
    static let subtitle: CGFloat = 15
}

struct LargeTitleHeader<Trailing: View>: View {
    let titleKey: LocalizedStringKey
    var subtitle: String?
    @ViewBuilder let trailing: Trailing

    init(
        titleKey: LocalizedStringKey,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.titleKey = titleKey
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LargeTitleHeaderLayout.spacing) {
            HStack(spacing: LargeTitleHeaderLayout.titleRowSpacing) {
                Text(titleKey)
                    .font(.elmsSans(.semiBold, LargeTitleHeaderLayout.title))
                    .tracking(LargeTitleHeaderLayout.titleTracking)
                    .foregroundStyle(Color.ink)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                trailing
            }

            if let subtitle {
                Text(verbatim: subtitle)
                    .font(.elmsSans(.regular, LargeTitleHeaderLayout.subtitle))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, LargeTitleHeaderLayout.horizontalPadding)
        .padding(.top, LargeTitleHeaderLayout.topPadding)
    }
}

extension LargeTitleHeader where Trailing == EmptyView {
    init(titleKey: LocalizedStringKey, subtitle: String? = nil) {
        self.init(titleKey: titleKey, subtitle: subtitle) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 32) {
        LargeTitleHeader(titleKey: "requests.title", subtitle: "2 нові заявки")
        LargeTitleHeader(titleKey: "myBookings.title")
        LargeTitleHeader(titleKey: "stats.title") {
            RoundIconButton(
                systemImage: "person.crop.circle",
                accessibilityLabel: "profile.action.open",
                action: {}
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.background)
}
