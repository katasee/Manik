import SwiftUI

struct ModeSwitcher: View {
    @Binding var mode: AuthViewModel.Mode
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: AuthMetrics.Spacing.segmentSpacing) {
            segment("auth.mode.signIn", isOn: mode == .signIn) {
                select(.signIn)
            }
            segment("auth.mode.signUp", isOn: mode == .signUp) {
                select(.signUp)
            }
        }
        .padding(AuthMetrics.Spacing.segmentTrackPadding)
        .background(Color.surface, in: .capsule)
    }

    private func select(_ newMode: AuthViewModel.Mode) {
        withAnimation(AuthMetrics.AnimationStyle.modeSwitch) {
            mode = newMode
        }
    }

    private func segment(
        _ title: LocalizedStringKey,
        isOn: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.elmsSans(.bold, AuthMetrics.FontSize.segmentLabel))
                .foregroundStyle(isOn ? .white : Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(AuthMetrics.Spacing.segmentPadding)
                .background {
                    if isOn {
                        Capsule()
                            .fill(Color.textPrimary)
                            .matchedGeometryEffect(id: "modeIndicator", in: namespace)
                            .brandShadow()
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
