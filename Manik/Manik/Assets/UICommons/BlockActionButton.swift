import SwiftUI

enum BlockActionButtonStyle {
    case popup
    case card
}

struct BlockActionButton: View {
    let action: BlockAction
    var style: BlockActionButtonStyle = .popup
    let isLoading: Bool
    let isEnabled: Bool
    let perform: (BlockAction) async -> Bool
    let onSuccess: () -> Void

    @State private var isConfirming = false

    @ViewBuilder
    var body: some View {
        if let confirmation = action.confirmation {
            button
                .alert(confirmation.titleKey, isPresented: $isConfirming) {
                    Button("common.action.cancel", role: .cancel) {}
                    Button(action.titleKey, role: .destructive, action: run)
                } message: {
                    Text(confirmation.messageKey)
                }
        } else {
            button
        }
    }

    @ViewBuilder
    private var button: some View {
        switch style {
        case .popup:
            PopupPrimaryButton(
                titleKey: action.titleKey,
                color: action.color,
                isLoading: isLoading,
                isEnabled: isEnabled,
                action: request
            )
        case .card:
            CardActionButton(
                titleKey: action.titleKey,
                systemImage: action.iconName,
                isProminent: action.isPreferred,
                isLoading: isLoading,
                isEnabled: isEnabled,
                action: request
            )
        }
    }

    private func request() {
        guard action.confirmation == nil else {
            isConfirming = true
            return
        }

        run()
    }

    private func run() {
        Task { @MainActor in
            if await perform(action) {
                onSuccess()
            }
        }
    }
}
