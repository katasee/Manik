import SwiftUI

struct VerifyEmailView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: VerifyEmailViewModel

    let onVerified: () async -> Void
    let onSignOut: () -> Void

    init(
        viewModel: VerifyEmailViewModel,
        onVerified: @escaping () async -> Void,
        onSignOut: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onVerified = onVerified
        self.onSignOut = onSignOut
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                IconBadge(systemName: "envelope.badge")
                    .padding(.bottom, AuthMetrics.Spacing.verifyIconBottom)

                Text("auth.verify.title")
                    .font(.elmsSans(.bold, AuthMetrics.FontSize.verifyTitle))
                    .foregroundStyle(Color.ink)
                    .accessibilityAddTraits(.isHeader)

                Text("auth.verify.message \(viewModel.email)")
                    .font(.elmsSans(.regular, AuthMetrics.FontSize.verifyBody))
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, AuthMetrics.Spacing.verifyMessageTop)

                messageText

                buttons
                    .padding(.top, AuthMetrics.Spacing.verifyButtonsTop)
            }
            .padding(.horizontal, AuthMetrics.Spacing.screenHorizontal)
            .padding(.vertical, AuthMetrics.Spacing.screenVertical)
        }
        .background(Color.background)
        .animation(PopupContainerLayout.fade, value: viewModel.message)
        .task(id: viewModel.cooldownRun) {
            await viewModel.runCooldown()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                checkSilently()
            }
        }
    }

    @ViewBuilder
    private var messageText: some View {
        if let message = viewModel.message {
            Text(message.messageKey)
                .font(.elmsSans(.regular, AuthMetrics.FontSize.error))
                .foregroundStyle(message.isError ? Color.destructive : Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, AuthMetrics.Spacing.errorTop)
        }
    }

    private var buttons: some View {
        VStack(spacing: AuthMetrics.Spacing.verifyButtons) {
            CapsuleButton(
                titleKey: "auth.verify.check",
                role: .primary,
                isLoading: viewModel.isChecking,
                fillsWidth: true,
                action: check
            )

            CapsuleButton(
                titleKey: resendTitle,
                role: .secondary,
                isLoading: viewModel.isResending,
                isEnabled: viewModel.canResend,
                fillsWidth: true,
                action: resend
            )

            Button("common.action.signOut", action: onSignOut)
                .buttonStyle(.plain)
                .font(.elmsSans(.medium, AuthMetrics.FontSize.swap))
                .foregroundStyle(Color.textSecondary)
                .frame(minHeight: AuthMetrics.swapTapHeight)
                .contentShape(.rect)
        }
    }

    private var resendTitle: LocalizedStringKey {
        if viewModel.resendSecondsLeft > 0 {
            "auth.verify.resendIn \(viewModel.resendSecondsLeft)"
        } else {
            "auth.verify.resend"
        }
    }

    private func check() {
        Task {
            if await viewModel.check(reportsPending: true) {
                await onVerified()
            }
        }
    }

    private func checkSilently() {
        Task {
            if await viewModel.check(reportsPending: false) {
                await onVerified()
            }
        }
    }

    private func resend() {
        Task {
            await viewModel.resend()
        }
    }
}

#if DEBUG
#Preview("Підтвердження") {
    VerifyEmailView(
        viewModel: VerifyEmailViewModel(
            email: "maria@example.com",
            authRepository: FakeAuthRepository(
                profile: UserProfile(
                    uid: "preview-master",
                    name: "Марія",
                    email: "maria@example.com"
                ),
                password: "secret1",
                isEmailVerified: false
            )
        ),
        onVerified: {},
        onSignOut: {}
    )
}

#Preview("Помилка") {
    VerifyEmailView(
        viewModel: VerifyEmailViewModel(
            email: "maria@example.com",
            authRepository: FailingAuthRepository(error: .tooManyRequests)
        ),
        onVerified: {},
        onSignOut: {}
    )
}
#endif
