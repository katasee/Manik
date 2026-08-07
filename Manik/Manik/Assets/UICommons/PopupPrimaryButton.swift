import SwiftUI

struct PopupPrimaryButton: View {
    let titleKey: LocalizedStringKey
    let color: Color
    let isLoading: Bool
    var isEnabled = true
    let action: () -> Void

    private enum Layout {
        static let minHeight: CGFloat = 44
        static let horizontalPadding: CGFloat = 20
        static let disabledOpacity: Double = 0.4
    }

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(titleKey)
                    .font(.elmsSans(.bold, 15))
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .frame(minHeight: Layout.minHeight)
        .padding(.horizontal, Layout.horizontalPadding)
        .background(color, in: .capsule)
        .disabled(isDisabled)
        .opacity(isDisabled ? Layout.disabledOpacity : 1)
    }

    private var isDisabled: Bool {
        isLoading || isEnabled == false
    }
}

#Preview {
    VStack(spacing: 12) {
        PopupPrimaryButton(
            titleKey: "schedule.createSlot.create",
            color: .ink,
            isLoading: false,
            action: {}
        )

        PopupPrimaryButton(
            titleKey: "schedule.createSlot.create",
            color: .ink,
            isLoading: false,
            isEnabled: false,
            action: {}
        )

        PopupPrimaryButton(
            titleKey: "schedule.createSlot.create",
            color: .ink,
            isLoading: true,
            action: {}
        )
    }
    .padding()
    .background(Color.background)
}
