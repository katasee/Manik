import SwiftUI

struct PopupDismissButton: View {
    let titleKey: LocalizedStringKey
    let action: () -> Void

    private enum Layout {
        static let minHeight: CGFloat = 44
        static let horizontalPadding: CGFloat = 4
    }

    var body: some View {
        Button(titleKey, action: action)
            .buttonStyle(.plain)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, Layout.horizontalPadding)
            .frame(minHeight: Layout.minHeight)
            .contentShape(.rect)
    }
}

#Preview {
    PopupDismissButton(titleKey: "schedule.createSlot.cancel", action: {})
        .padding()
        .background(Color.background)
}
