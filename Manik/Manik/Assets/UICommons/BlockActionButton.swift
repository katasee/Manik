import SwiftUI

struct BlockActionButton: View {
    let action: BlockAction
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

    private var button: some View {
        CardActionButton(
            titleKey: action.titleKey,
            systemImage: action.iconName,
            isProminent: action.isPreferred,
            isLoading: isLoading,
            isEnabled: isEnabled,
            action: request
        )
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
