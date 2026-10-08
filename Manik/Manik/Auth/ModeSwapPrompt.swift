import SwiftUI

struct ModeSwapPrompt: View {
    @Binding var mode: AuthViewModel.Mode

    private var promptKey: LocalizedStringKey {
        mode == .signIn ? "auth.swap.noAccount" : "auth.swap.haveAccount"
    }

    private var actionKey: LocalizedStringKey {
        mode == .signIn ? "auth.action.signUp" : "auth.mode.signIn"
    }

    var body: some View {
        HStack(spacing: AuthMetrics.Spacing.swapSpacing) {
            Text(promptKey)
                .font(.elmsSans(.regular, AuthMetrics.FontSize.swap))
                .foregroundStyle(Color.textSecondary)

            Button(action: toggle) {
                Text(actionKey)
                    .font(.elmsSans(.semiBold, AuthMetrics.FontSize.swap))
                    .foregroundStyle(Color.wine)
                    .underline()
                    .frame(minHeight: AuthMetrics.swapTapHeight)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private func toggle() {
        withAnimation(AuthMetrics.AnimationStyle.modeSwitch) {
            mode = mode == .signIn ? .signUp : .signIn
        }
    }
}

#Preview {
    @Previewable @State var mode = AuthViewModel.Mode.signIn

    ModeSwapPrompt(mode: $mode)
        .padding()
        .background(Color.background)
}
