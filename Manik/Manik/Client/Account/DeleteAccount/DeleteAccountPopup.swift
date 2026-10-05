import SwiftUI

struct DeleteAccountPopup: View {
    @State private var viewModel: DeleteAccountViewModel
    @FocusState private var isPasswordFocused: Bool

    let onDeleted: () -> Void
    let onDismiss: () -> Void

    init(
        viewModel: DeleteAccountViewModel,
        onDeleted: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDeleted = onDeleted
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(
            dismissLabel: "common.action.cancel",
            onDismiss: onDismiss
        ) { dismiss in
            Text("account.delete.title")
                .font(.elmsSans(.bold, 18))
                .foregroundStyle(Color.ink)

            Text("account.delete.note")
                .font(.elmsSans(.regular, 14))
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            warning
            passwordField
            failureText

            HStack {
                PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

                Spacer()

                CapsuleButton(
                    titleKey: "account.delete.confirm",
                    role: .destructive,
                    isLoading: viewModel.isDeleting,
                    isEnabled: viewModel.canSubmit,
                    action: delete
                )
            }
        }
        .animation(PopupContainerLayout.fade, value: viewModel.failure != nil)
    }

    @ViewBuilder
    private var warning: some View {
        if viewModel.upcomingCount > 0 {
            Text("account.delete.warning \(viewModel.upcomingCount)")
                .font(.elmsSans(.semiBold, 13))
                .foregroundStyle(Color.destructive)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: AccountMetrics.Spacing.cardContentSpacing) {
            SectionLabel(titleKey: "account.password.current")

            SecureField("account.password.placeholder", text: $viewModel.password)
                .textContentType(.password)
                .focused($isPasswordFocused)
                .submitLabel(.done)
                .inputFieldStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var failureText: some View {
        if let failure = viewModel.failure {
            Text(failure.messageKey)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func delete() {
        isPasswordFocused = false

        Task { @MainActor in
            if await viewModel.delete() {
                onDeleted()
            }
        }
    }
}

#if DEBUG
#Preview("Видалення") {
    Color.background
        .overlay {
            DeleteAccountPopup(
                viewModel: DeleteAccountViewModel(
                    uid: AccountPreviewData.uid,
                    upcomingBookingIds: ["upcoming", "upcoming-2"],
                    authRepository: FakeAuthRepository(
                        profile: AccountPreviewData.profile,
                        password: AccountPreviewData.password
                    ),
                    userRepository: FakeUserRepository(profiles: AccountPreviewData.profiles),
                    blockRepository: FakeBlockRepository(blocks: AccountPreviewData.blocks)
                ),
                onDeleted: {},
                onDismiss: {}
            )
        }
}

#Preview("Без записів") {
    Color.background
        .overlay {
            DeleteAccountPopup(
                viewModel: DeleteAccountViewModel(
                    uid: AccountPreviewData.uid,
                    upcomingBookingIds: [],
                    authRepository: FakeAuthRepository(
                        profile: AccountPreviewData.profile,
                        password: AccountPreviewData.password
                    ),
                    userRepository: FakeUserRepository(profiles: AccountPreviewData.profiles),
                    blockRepository: FakeBlockRepository()
                ),
                onDeleted: {},
                onDismiss: {}
            )
        }
}

#Preview("Помилка") {
    Color.background
        .overlay {
            DeleteAccountPopup(
                viewModel: DeleteAccountViewModel(
                    uid: AccountPreviewData.uid,
                    upcomingBookingIds: ["upcoming"],
                    authRepository: FakeAuthRepository(
                        profile: AccountPreviewData.profile,
                        password: AccountPreviewData.password
                    ),
                    userRepository: FakeUserRepository(profiles: [:]),
                    blockRepository: FakeBlockRepository(blocks: AccountPreviewData.blocks)
                ),
                onDeleted: {},
                onDismiss: {}
            )
        }
}
#endif
