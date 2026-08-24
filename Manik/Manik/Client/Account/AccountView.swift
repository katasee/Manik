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
        .task {
            await viewModel.observeBlocks()
        }
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

            VStack(spacing: 0) {
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
            .cardSurface(
                padding: AccountMetrics.Spacing.cardPadding,
                cornerRadius: AccountMetrics.Size.cardCornerRadius
            )
        }
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: AccountMetrics.Spacing.rowSpacing) {
            sectionLabel("account.section.stats")

            Grid(horizontalSpacing: AccountMetrics.Spacing.cardSpacing) {
                GridRow {
                    StatCard(
                        iconName: "checkmark.circle",
                        tint: Color.statusConfirmed,
                        value: viewModel.stats.visitCount.formatted(),
                        titleKey: "account.stats.visits"
                    )

                    StatCard(
                        iconName: "heart",
                        tint: Color.freeSlot,
                        value: favoriteServiceName,
                        titleKey: "account.stats.favorite",
                        valueLineLimit: 2
                    )
                }
            }
            .redacted(reason: viewModel.hasLoadedStats ? [] : .placeholder)
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
                .frame(maxWidth: .infinity)
                .cardSurface(
                    padding: AccountMetrics.Spacing.signOutPadding,
                    cornerRadius: AccountMetrics.Size.cardCornerRadius
                )
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
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
            userRepository: FakeUserRepository(profiles: AccountPreviewData.profiles),
            blockRepository: FakeBlockRepository(blocks: AccountPreviewData.blocks),
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
            blockRepository: FakeBlockRepository(),
            onProfileUpdated: { _ in }
        ),
        onSignOut: {}
    )
}
#endif
