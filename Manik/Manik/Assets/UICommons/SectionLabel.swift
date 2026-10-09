import SwiftUI

struct SectionLabel: View {
    let titleKey: LocalizedStringKey

    private enum Layout {
        static let size: CGFloat = 12
        static let tracking: CGFloat = 1.4
    }

    var body: some View {
        Text(titleKey)
            .font(.elmsSans(.semiBold, Layout.size))
            .tracking(Layout.tracking)
            .textCase(.uppercase)
            .foregroundStyle(Color.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    SectionLabel(titleKey: "profile.section.account")
        .padding()
        .background(Color.background)
}
