import SwiftUI

private struct AppearanceOptionRow: View {
    let option: AppAppearance
    let isSelected: Bool
    let onSelect: () -> Void

    private enum Layout {
        static let icon: CGFloat = 18
        static let iconColumn: CGFloat = 24
        static let spacing: CGFloat = 12
        static let minHeight: CGFloat = 48
        static let checkmark: CGFloat = 15
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Layout.spacing) {
                Image(systemName: option.systemImage)
                    .font(.elmsSans(.medium, Layout.icon))
                    .foregroundStyle(Color.ink)
                    .frame(width: Layout.iconColumn)
                    .accessibilityHidden(true)

                Text(option.titleKey)
                    .font(.elmsSans(.semiBold, 15))
                    .foregroundStyle(Color.ink)

                Spacer()

                Image(systemName: "checkmark")
                    .font(.elmsSans(.bold, Layout.checkmark))
                    .foregroundStyle(Color.accentColor)
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: Layout.minHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct AppearancePicker: View {
    @AppStorage(AppAppearance.storageKey) private var appearance: AppAppearance = .system

    var body: some View {
        VStack(spacing: 0) {
            ForEach(AppAppearance.allCases) { option in
                if option != AppAppearance.allCases.first {
                    Color.hairline
                        .frame(height: 1)
                }

                AppearanceOptionRow(option: option, isSelected: option == appearance) {
                    appearance = option
                }
            }
        }
    }
}

#Preview {
    AppearancePicker()
        .padding()
        .background(Color.background)
}
