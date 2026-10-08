import SwiftUI

enum CapsuleButtonRole {
    case primary
    case secondary
    case destructive
}

struct CapsuleButton: View {
    let titleKey: LocalizedStringKey
    let role: CapsuleButtonRole
    var systemImage: String?
    var isLoading = false
    var isEnabled = true
    var fillsWidth = false
    let action: () -> Void

    private enum Layout {
        static let minHeight: CGFloat = 50
        static let horizontalPadding: CGFloat = 22
        static let iconSpacing: CGFloat = 6
        static let title: CGFloat = 16
        static let icon: CGFloat = 14
        static let titleScale: CGFloat = 0.8
        static let disabledOpacity: Double = 0.4
        static let destructiveShadowOpacity: Double = 0.25
        static let destructiveShadowRadius: CGFloat = 8
        static let destructiveShadowY: CGFloat = 6
    }

    private var labelColor: Color {
        role == .secondary ? Color.ink : Color.onPrimary
    }

    private var isDisabled: Bool {
        isLoading || isEnabled == false
    }

    var body: some View {
        Button(action: action) {
            label
                .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: Layout.minHeight)
                .padding(.horizontal, Layout.horizontalPadding)
                .background { background }
                .contentShape(.capsule)
        }
        .buttonStyle(PressableButtonStyle())
        .foregroundStyle(labelColor)
        .disabled(isDisabled)
        .opacity(isDisabled ? Layout.disabledOpacity : 1)
    }

    @ViewBuilder
    private var label: some View {
        if isLoading {
            ProgressView()
                .tint(labelColor)
        } else {
            HStack(spacing: Layout.iconSpacing) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.elmsSans(.bold, Layout.icon))
                        .accessibilityHidden(true)
                }

                Text(titleKey)
                    .font(.elmsSans(.semiBold, Layout.title))
                    .lineLimit(1)
                    .minimumScaleFactor(Layout.titleScale)
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        switch role {
        case .primary:
            Capsule()
                .fill(Color.primaryFill)
                .brandShadow(isDisabled == false)
        case .secondary:
            Color.clear
                .raisedSurface(.capsule)
        case .destructive:
            Capsule()
                .fill(Color.destructiveFill)
                .shadow(
                    color: Color.destructiveFill.opacity(isDisabled ? 0 : Layout.destructiveShadowOpacity),
                    radius: Layout.destructiveShadowRadius,
                    x: 0,
                    y: Layout.destructiveShadowY
                )
        }
    }
}

private struct PressableButtonStyle: ButtonStyle {
    private enum Layout {
        static let pressedScale: CGFloat = 0.97
        static let pressedOpacity: Double = 0.75
        static let press = Animation.easeOut(duration: 0.12)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Layout.pressedScale : 1)
            .opacity(configuration.isPressed ? Layout.pressedOpacity : 1)
            .animation(Layout.press, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        CapsuleButton(titleKey: "schedule.createSlot.create", role: .primary, action: {})

        CapsuleButton(
            titleKey: "schedule.createSlot.create",
            role: .primary,
            isEnabled: false,
            action: {}
        )

        CapsuleButton(
            titleKey: "myBookings.cancel.confirm",
            role: .destructive,
            isLoading: true,
            action: {}
        )

        HStack(spacing: 10) {
            CapsuleButton(
                titleKey: "schedule.action.decline",
                role: .secondary,
                fillsWidth: true,
                action: {}
            )

            CapsuleButton(
                titleKey: "schedule.action.confirm",
                role: .primary,
                systemImage: "checkmark",
                fillsWidth: true,
                action: {}
            )
        }

        HStack(spacing: 10) {
            CapsuleButton(
                titleKey: "schedule.action.cancelBooking",
                role: .secondary,
                isLoading: true,
                fillsWidth: true,
                action: {}
            )

            CapsuleButton(
                titleKey: "schedule.action.confirm",
                role: .primary,
                isEnabled: false,
                fillsWidth: true,
                action: {}
            )
        }
    }
    .padding()
    .background(Color.background)
}
