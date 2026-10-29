import SwiftUI

struct AuthView: View {
    @State private var viewModel = AuthViewModel()
    @FocusState private var focusedField: AuthFocusField?
    @State private var isShowingReset = false
    var onAuthenticated: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                title

                VStack(spacing: AuthMetrics.Spacing.fieldStack) {
                    if viewModel.mode == .signUp {
                        AuthFieldView(
                            "auth.field.name",
                            text: $viewModel.name,
                            focusField: .name,
                            focusedField: $focusedField,
                            textContentType: .name
                        )
                    }

                    AuthFieldView(
                        "auth.field.email",
                        text: $viewModel.email,
                        focusField: .email,
                        focusedField: $focusedField,
                        textContentType: .emailAddress,
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        autocorrectionDisabled: true
                    )

                    AuthFieldView(
                        "auth.field.password",
                        text: $viewModel.password,
                        isSecure: true,
                        focusField: .password,
                        focusedField: $focusedField,
                        textContentType: viewModel.mode == .signIn ? .password : .newPassword
                    )
                }

                if viewModel.mode == .signIn {
                    forgotPasswordLink
                }

                if let failure = viewModel.failure {
                    errorText(failure.messageKey)
                }

                submitButton
                    .padding(.top, AuthMetrics.Spacing.submitTop)

                ModeSwapPrompt(mode: $viewModel.mode)
                    .padding(.top, AuthMetrics.Spacing.swapTop)
            }
            .padding(.horizontal, AuthMetrics.Spacing.screenHorizontal)
            .padding(.vertical, AuthMetrics.Spacing.screenVertical)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.background)
        .onAppear {
            focusedField = .email
        }
        .fullScreenCover(isPresented: $isShowingReset) {
            ResetPasswordPopup(
                viewModel: ResetPasswordViewModel(email: viewModel.email),
                onDismiss: hideReset
            )
            .presentationBackground(.clear)
        }
    }

    private func errorText(_ message: LocalizedStringKey) -> some View {
        Text(message)
            .font(.elmsSans(.regular, AuthMetrics.FontSize.error))
            .foregroundStyle(.red)
            .padding(.top, AuthMetrics.Spacing.errorTop)
    }

    private var forgotPasswordLink: some View {
        Button(action: showReset) {
            Text("auth.action.forgotPassword")
                .font(.elmsSans(.semiBold, AuthMetrics.FontSize.swap))
                .foregroundStyle(Color.wine)
                .frame(minHeight: AuthMetrics.swapTapHeight)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func showReset() {
        focusedField = nil

        withoutPresentationAnimation {
            isShowingReset = true
        }
    }

    private func hideReset() {
        withoutPresentationAnimation {
            isShowingReset = false
        }
    }

    @ViewBuilder
    private var title: some View {
        Text("appTitle")
            .font(.elmsSans(.bold, AuthMetrics.FontSize.title))
            .foregroundStyle(Color.ink)

        Text("auth.tagline")
            .font(.elmsSans(.regular, AuthMetrics.FontSize.tagline))
            .foregroundStyle(Color.textSecondary)
            .padding(.bottom, AuthMetrics.Spacing.taglineBottom)
    }

    private func handleSubmit() {
        Task {
            if await viewModel.submit() {
                await onAuthenticated()
            }
        }
    }

    private var submitButton: some View {
        CapsuleButton(
            titleKey: viewModel.mode == .signIn ? "auth.mode.signIn" : "auth.action.signUp",
            role: .primary,
            isLoading: viewModel.isLoading,
            isEnabled: viewModel.canSubmit,
            fillsWidth: true,
            action: handleSubmit
        )
    }
}

#Preview {
    AuthView(onAuthenticated: {})
}
