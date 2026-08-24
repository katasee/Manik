import SwiftUI

struct AccountRow: View {
    let iconName: String
    let labelKey: LocalizedStringKey
    let value: String?

    var body: some View {
        HStack(spacing: AccountMetrics.Spacing.inlineSpacing) {
            Image(systemName: iconName)
                .font(.elmsSans(.regular, AccountMetrics.Size.rowIcon))
                .foregroundStyle(.black)
                .frame(width: AccountMetrics.Size.rowIcon)

            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)

            Spacer()

            valueText
                .font(.elmsSans(.regular, 15))
        }
        .frame(minHeight: AccountMetrics.Size.rowHeight)
    }

    @ViewBuilder
    private var valueText: some View {
        if let value {
            Text(value)
                .foregroundStyle(Color.ink)
        } else {
            Text("account.field.empty")
                .foregroundStyle(Color.textSecondary)
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        AccountRow(
            iconName: "phone.fill",
            labelKey: "account.field.phone",
            value: "+48 600 123 456"
        )

        AccountRow(
            iconName: "paperplane.fill",
            labelKey: "account.field.telegram",
            value: nil
        )
    }
    .padding()
    .background(Color.background)
}
#endif
