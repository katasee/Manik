import SwiftUI

struct SectionLabel: View {
    let titleKey: LocalizedStringKey
    var count: Int?

    private enum Layout {
        static let size: CGFloat = 12
        static let tracking: CGFloat = 1.4
        static let countSpacing: CGFloat = 6
    }

    var body: some View {
        HStack(spacing: Layout.countSpacing) {
            Text(titleKey)
                .tracking(Layout.tracking)
                .textCase(.uppercase)

            if let count {
                Text(verbatim: "·")

                Text(count.formatted())
                    .font(.elmsSans(.bold, Layout.size))
                    .foregroundStyle(Color.ink)
            }
        }
        .font(.elmsSans(.semiBold, Layout.size))
        .foregroundStyle(Color.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SectionLabel(titleKey: "profile.section.account")
        SectionLabel(titleKey: "services.section.all", count: 4)
    }
    .padding()
    .background(Color.background)
}
