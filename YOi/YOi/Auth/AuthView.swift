import SwiftUI

struct AuthView: View {
    @State private var viewModel = AuthViewModel()
    @FocusState private var focusedField: AuthFocusField?
    @State private var isShowingReset = false
    @Environment(\.openURL) private var openURL
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

                if viewModel.mode == .signUp {
                    consentButton
                        .padding(.top, AuthMetrics.Spacing.consentTop)
                }

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

    private var consentButton: some View {
        Button(action: openPrivacyPolicy) {
            Text(consentText)
                .font(.elmsSans(.regular, AuthMetrics.FontSize.swap))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: .infinity,
                    minHeight: AuthMetrics.swapTapHeight,
                    alignment: .leading
                )
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var consentText: AttributedString {
        var policyName = AttributedString(localized: "auth.consent.link")
        policyName.foregroundColor = Color.wine
        policyName.underlineStyle = .single
        return AttributedString(localized: "auth.consent \(policyName)")
    }

    private func openPrivacyPolicy() {
        openURL(AppLinks.privacyPolicy)
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
