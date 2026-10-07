import SwiftUI

struct RoundIconButton: View {
    enum Size {
        case regular
        case small

        var diameter: CGFloat {
            switch self {
            case .regular: 44
            case .small: 36
            }
        }

        var glyph: CGFloat {
            switch self {
            case .regular: 16
            case .small: 14
            }
        }
    }

    let systemImage: String
    var size: Size = .regular
    let accessibilityLabel: LocalizedStringKey
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    private enum Layout {
        static let tapTarget: CGFloat = 44
        static let disabledOpacity: Double = 0.35
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.elmsSans(.medium, size.glyph))
                .foregroundStyle(Color.accentColor)
                .frame(width: size.diameter, height: size.diameter)
                .raisedSurface(.circle)
                .frame(width: Layout.tapTarget, height: Layout.tapTarget)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : Layout.disabledOpacity)
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

#Preview {
    HStack(spacing: 16) {
        RoundIconButton(
            systemImage: "plus",
            accessibilityLabel: "services.action.add",
            action: {}
        )

        RoundIconButton(
            systemImage: "chevron.left",
            size: .small,
            accessibilityLabel: "common.action.back",
            action: {}
        )

        RoundIconButton(
            systemImage: "chevron.right",
            size: .small,
            accessibilityLabel: "booking.calendar.nextMonth",
            action: {}
        )
        .disabled(true)
    }
    .padding()
    .background(Color.background)
}
