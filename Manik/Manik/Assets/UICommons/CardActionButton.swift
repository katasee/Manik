import SwiftUI

struct CardActionButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    let isProminent: Bool
    let isLoading: Bool
    var isEnabled = true
    let action: () -> Void

    private enum Layout {
        static let minHeight: CGFloat = 48
        static let iconSpacing: CGFloat = 6
        static let iconSize: CGFloat = 13
        static let titleSize: CGFloat = 15
        static let strokeWidth: CGFloat = 1
        static let strokeOpacity: Double = 0.12
        static let quietLabelOpacity: Double = 0.65
        static let disabledOpacity: Double = 0.4
    }

    private var labelColor: Color {
        isProminent ? Color.white : Color.ink.opacity(Layout.quietLabelOpacity)
    }

    var body: some View {
        Button(action: action) {
            label
                .frame(maxWidth: .infinity, minHeight: Layout.minHeight)
                .background(background)
                .contentShape(.capsule)
        }
        .buttonStyle(CardActionButtonStyle())
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
                Image(systemName: systemImage)
                    .font(.elmsSans(.bold, Layout.iconSize))
                    .accessibilityHidden(true)

                Text(titleKey)
                    .font(.elmsSans(.bold, Layout.titleSize))
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        if isProminent {
            Capsule().fill(Color.ink)
        } else {
            Capsule().strokeBorder(
                Color.ink.opacity(Layout.strokeOpacity),
                lineWidth: Layout.strokeWidth
            )
        }
    }

    private var isDisabled: Bool {
        isLoading || isEnabled == false
    }
}

private struct CardActionButtonStyle: ButtonStyle {
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
        HStack(spacing: 10) {
            CardActionButton(
                titleKey: "schedule.action.decline",
                systemImage: "xmark",
                isProminent: false,
                isLoading: false,
                action: {}
            )

            CardActionButton(
                titleKey: "schedule.action.confirm",
                systemImage: "checkmark",
                isProminent: true,
                isLoading: false,
                action: {}
            )
        }

        HStack(spacing: 10) {
            CardActionButton(
                titleKey: "schedule.action.decline",
                systemImage: "xmark",
                isProminent: false,
                isLoading: false,
                isEnabled: false,
                action: {}
            )

            CardActionButton(
                titleKey: "schedule.action.confirm",
                systemImage: "checkmark",
                isProminent: true,
                isLoading: true,
                action: {}
            )
        }
    }
    .padding()
    .background(Color.surface)
}
