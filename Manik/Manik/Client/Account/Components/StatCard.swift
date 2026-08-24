import SwiftUI

struct StatCard: View {
    let value: String
    let labelKey: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: AccountMetrics.Spacing.cardContentSpacing) {
            Text(value)
                .font(.elmsSans(.bold, 22))
                .foregroundStyle(Color.ink)
                .lineLimit(2)
                .minimumScaleFactor(AccountMetrics.Size.statValueScale)

            Text(labelKey)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AccountMetrics.Spacing.cardPadding)
        .background(
            Color.surface,
            in: .rect(cornerRadius: AccountMetrics.Size.cardCornerRadius)
        )
    }
}

#if DEBUG
#Preview {
    HStack(alignment: .top, spacing: 12) {
        StatCard(value: "12", labelKey: "account.stats.visits")
            .frame(maxHeight: .infinity)

        StatCard(value: "Манікюр + гель-лак", labelKey: "account.stats.favorite")
            .frame(maxHeight: .infinity)
    }
    .fixedSize(horizontal: false, vertical: true)
    .padding()
    .background(Color.background)
}
#endif
