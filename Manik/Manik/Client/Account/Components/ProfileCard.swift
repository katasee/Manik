import SwiftUI

struct ProfileCard: View {
    let name: String
    let email: String
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: AccountMetrics.Spacing.inlineSpacing) {
            avatar

            VStack(alignment: .leading, spacing: AccountMetrics.Spacing.cardContentSpacing) {
                Text(name)
                    .font(.elmsSans(.bold, 18))
                    .foregroundStyle(Color.ink)

                Text(email)
                    .font(.elmsSans(.regular, 14))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            editButton
        }
        .padding(AccountMetrics.Spacing.cardPadding)
        .background(
            Color.surface,
            in: .rect(cornerRadius: AccountMetrics.Size.cardCornerRadius)
        )
    }

    private var avatar: some View {
        Circle()
            .fill(Color.background)
            .frame(
                width: AccountMetrics.Size.avatar,
                height: AccountMetrics.Size.avatar
            )
            .overlay {
                Text(initials)
                    .font(.elmsSans(.bold, 22))
                    .foregroundStyle(Color.ink)
            }
    }

    private var editButton: some View {
        Button("account.action.edit", systemImage: "pencil", action: onEdit)
            .labelStyle(.iconOnly)
            .font(.elmsSans(.regular, AccountMetrics.Size.rowIcon))
            .foregroundStyle(Color.ink)
            .frame(
                minWidth: AccountMetrics.Size.tapTarget,
                minHeight: AccountMetrics.Size.tapTarget
            )
            .contentShape(.rect)
    }

    private var initials: String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)

        return String(letters).uppercased()
    }
}

#if DEBUG
#Preview {
    ProfileCard(
        name: "Олена Ковальчук",
        email: "olena@example.com",
        onEdit: {}
    )
    .padding()
    .background(Color.background)
}
#endif
