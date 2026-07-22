import SwiftUI

struct AuthView: View {
    @State private var viewModel = AuthViewModel()
    @FocusState private var focusedField: AuthFocusField?
    var onAuthenticated: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                title

                ModeSwitcher(mode: $viewModel.mode)
                    .padding(.bottom, AuthMetrics.Spacing.modeSwitcherBottom)

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

                if let errorMessage = viewModel.errorMessage {
                    errorText(errorMessage)
                }

                submitButton
                    .padding(.top, AuthMetrics.Spacing.submitTop)
            }
            .padding(.horizontal, AuthMetrics.Spacing.screenHorizontal)
            .padding(.vertical, AuthMetrics.Spacing.screenVertical)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.background)
        .onAppear {
            focusedField = .email
        }
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(.elmsSans(.regular, AuthMetrics.FontSize.error))
            .foregroundStyle(.red)
            .padding(.top, AuthMetrics.Spacing.errorTop)
    }

    @ViewBuilder
    private var title: some View {
        Text("appTitle")
            .font(.elmsSans(.bold, AuthMetrics.FontSize.title))
            .foregroundStyle(Color.textPrimary)

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
        Button(action: handleSubmit) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.mode == .signIn {
                    Text("auth.mode.signIn")
                        .font(.elmsSans(.bold, AuthMetrics.FontSize.submitLabel))
                } else {
                    Text("auth.action.signUp")
                        .font(.elmsSans(.bold, AuthMetrics.FontSize.submitLabel))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AuthMetrics.Spacing.submitVerticalPadding)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(Color.textPrimary, in: .capsule)
        .brandShadow()
        .disabled(viewModel.isLoading || !viewModel.canSubmit)
        .opacity(viewModel.isLoading || !viewModel.canSubmit ? AuthMetrics.disabledOpacity : 1)
    }
}

#Preview {
    AuthView(onAuthenticated: {})
}
