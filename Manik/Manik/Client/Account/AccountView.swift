import SwiftUI

struct AccountView: View {
    private enum AccountPopup: String, Identifiable {
        case profileForm
        case changePassword
        case deleteAccount

        var id: String { rawValue }
    }

    @State private var viewModel: AccountViewModel
    @State private var popup: AccountPopup?

    let onSignOut: () -> Void
    let onAccountDeleted: () -> Void

    init(
        viewModel: AccountViewModel,
        onSignOut: @escaping () -> Void,
        onAccountDeleted: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSignOut = onSignOut
        self.onAccountDeleted = onAccountDeleted
    }

    var body: some View {
        VStack(spacing: 0) {
            LargeTitleHeader(titleKey: "account.title")

            ScrollView {
                VStack(alignment: .leading, spacing: AccountMetrics.Spacing.sectionSpacing) {
                    ProfileCard(
                        name: viewModel.profile.name,
                        email: viewModel.profile.email,
                        onEdit: showProfileForm
                    )

                    contacts

                    stats

                    actions
                }
                .padding(.horizontal, AccountMetrics.Spacing.horizontalPadding)
                .padding(.top, AccountMetrics.Spacing.contentTopPadding)
                .padding(.bottom, AccountMetrics.Spacing.contentBottomPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            await viewModel.observeBlocks()
        }
        .fullScreenCover(item: $popup) { popup in
            popupView(popup)
                .presentationBackground(.clear)
        }
    }

    @ViewBuilder
    private func popupView(_ popup: AccountPopup) -> some View {
        switch popup {
        case .profileForm:
            ProfileFormPopup(
                viewModel: viewModel.makeProfileFormViewModel(),
                onSaved: viewModel.apply,
                onDismiss: dismissPopup
            )
        case .changePassword:
            ChangePasswordPopup(
                viewModel: viewModel.makeChangePasswordViewModel(),
                onDismiss: dismissPopup
            )
        case .deleteAccount:
            DeleteAccountPopup(
                viewModel: viewModel.makeDeleteAccountViewModel(),
                onDeleted: onAccountDeleted,
                onDismiss: dismissPopup
            )
        }
    }

    private func show(_ popup: AccountPopup) {
        withoutPresentationAnimation {
            self.popup = popup
        }
    }

    private func dismissPopup() {
        withoutPresentationAnimation {
            popup = nil
        }
    }

    private func showProfileForm() {
        show(.profileForm)
    }

    private func showChangePassword() {
        show(.changePassword)
    }

    private func showDeleteAccount() {
        show(.deleteAccount)
    }

    private var contacts: some View {
        VStack(alignment: .leading, spacing: AccountMetrics.Spacing.rowSpacing) {
            SectionLabel(titleKey: "account.section.contacts")

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
            SectionLabel(titleKey: "account.section.stats")

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

    private var actions: some View {
        VStack(spacing: AccountMetrics.Spacing.rowSpacing) {
            actionButton(
                titleKey: "account.action.changePassword",
                tint: Color.ink,
                action: showChangePassword
            )

            actionButton(
                titleKey: "common.action.signOut",
                tint: Color.ink,
                action: onSignOut
            )

            actionButton(
                titleKey: "account.action.delete",
                tint: Color.destructive,
                action: showDeleteAccount
            )
            .disabled(viewModel.hasLoadedStats == false)
        }
    }

    private func actionButton(
        titleKey: LocalizedStringKey,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(titleKey)
                .font(.elmsSans(.bold, 14.5))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .cardSurface(
                    padding: AccountMetrics.Spacing.actionPadding,
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
        onSignOut: {},
        onAccountDeleted: {}
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
        onSignOut: {},
        onAccountDeleted: {}
    )
}
#endif
