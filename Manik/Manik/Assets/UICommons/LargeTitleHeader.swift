import SwiftUI

struct LargeTitleHeader: View {
    let titleKey: LocalizedStringKey
    var subtitle: String?

    private enum Layout {
        static let spacing: CGFloat = 6
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 12
        static let title: CGFloat = 32
        static let titleTracking: CGFloat = -0.6
        static let subtitle: CGFloat = 15
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text(titleKey)
                .font(.elmsSans(.semiBold, Layout.title))
                .tracking(Layout.titleTracking)
                .foregroundStyle(Color.ink)
                .accessibilityAddTraits(.isHeader)

            if let subtitle {
                Text(verbatim: subtitle)
                    .font(.elmsSans(.regular, Layout.subtitle))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.top, Layout.topPadding)
    }
}

#Preview {
    VStack(spacing: 32) {
        LargeTitleHeader(titleKey: "requests.title", subtitle: "2 нові заявки")
        LargeTitleHeader(titleKey: "myBookings.title")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.background)
}
