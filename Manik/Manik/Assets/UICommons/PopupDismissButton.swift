import SwiftUI

struct PopupDismissButton: View {
    let titleKey: LocalizedStringKey
    let action: () -> Void

    private enum Layout {
        static let minHeight: CGFloat = 44
    }

    var body: some View {
        Button(titleKey, action: action)
            .buttonStyle(.plain)
            .font(.elmsSans(.semiBold, 15))
            .foregroundStyle(Color.textSecondary)
            .frame(minHeight: Layout.minHeight)
    }
}

#Preview {
    PopupDismissButton(titleKey: "schedule.createSlot.cancel", action: {})
        .padding()
        .background(Color.background)
}
