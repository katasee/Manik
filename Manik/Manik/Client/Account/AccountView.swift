import SwiftUI

struct AccountView: View {
    @State private var viewModel: AccountViewModel
    @State private var isEditing = false

    let onSignOut: () -> Void

    init(viewModel: AccountViewModel, onSignOut: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignOut = onSignOut
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(titleKey: "account.title")

            ScrollView {
                VStack(alignment: .leading, spacing: AccountMetrics.Spacing.sectionSpacing) {
                    ProfileCard(
                        name: viewModel.profile.name,
                        email: viewModel.profile.email,
                        onEdit: showForm
                    )

                    contacts

                    stats

                    signOut
                }
                .padding(.horizontal, AccountMetrics.Spacing.horizontalPadding)
                .padding(.top, AccountMetrics.Spacing.contentTopPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .fullScreenCover(isPresented: $isEditing) {
            ProfileFormPopup(
                viewModel: viewModel.makeProfileFormViewModel(),
                onSaved: viewModel.apply,
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    private func showForm() {
        withoutPresentationAnimation {
            isEditing = true
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            isEditing = false
        }
    }

    private var contacts: some View {
        VStack(alignment: .leading, spacing: AccountMetrics.Spacing.rowSpacing) {
            sectionLabel("account.section.contacts")

            AccountRow(
                iconName: "phone.fill",
                labelKey: "account.field.phone",
                value: PhoneFormat.display(viewModel.profile.phone)
            )

            AccountRow(
                iconName: "camera.fill",
                labelKey: "account.field.instagram",
                value: handle(viewModel.profile.instagram)
            )

            AccountRow(
                iconName: "paperplane.fill",
                labelKey: "account.field.telegram",
                value: handle(viewModel.profile.telegram)
            )
        }
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: AccountMetrics.Spacing.rowSpacing) {
            sectionLabel("account.section.stats")

            HStack(alignment: .top, spacing: AccountMetrics.Spacing.inlineSpacing) {
                StatCard(
                    value: viewModel.stats.visitCount.formatted(),
                    labelKey: "account.stats.visits"
                )
                .frame(maxHeight: .infinity)

                StatCard(
                    value: favoriteServiceName,
                    labelKey: "account.stats.favorite"
                )
                .frame(maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var favoriteServiceName: String {
        viewModel.stats.favoriteServiceName ?? String(localized: "account.stats.empty")
    }

    private func sectionLabel(_ titleKey: LocalizedStringKey) -> some View {
        Text(titleKey)
            .font(.elmsSans(.semiBold, 13))
            .tracking(AccountMetrics.Tracking.sectionLabel)
            .textCase(.uppercase)
            .foregroundStyle(Color.textSecondary)
    }

    private var signOut: some View {
        Button(action: onSignOut) {
            Text("common.action.signOut")
                .font(.elmsSans(.bold, 14.5))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity, minHeight: AccountMetrics.Size.tapTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background(
            Color.surface,
            in: .rect(cornerRadius: AccountMetrics.Size.cardCornerRadius)
        )
    }

    private func handle(_ value: String?) -> String? {
        value.map { "@\($0)" }
    }
}

#if DEBUG
#Preview("Заповнений профіль") {
    AccountView(
        viewModel: AccountViewModel(
            profile: AccountPreviewData.profile,
            stats: AccountPreviewData.stats,
            userRepository: FakeUserRepository(profiles: AccountPreviewData.profiles),
            onProfileUpdated: { _ in }
        ),
        onSignOut: {}
    )
}

#Preview("Порожній профіль") {
    AccountView(
        viewModel: AccountViewModel(
            profile: AccountPreviewData.emptyContactsProfile,
            userRepository: FakeUserRepository(profiles: AccountPreviewData.profiles),
            onProfileUpdated: { _ in }
        ),
        onSignOut: {}
    )
}
#endif
