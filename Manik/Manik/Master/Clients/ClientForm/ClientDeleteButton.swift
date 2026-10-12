import SwiftUI

struct ClientDeleteButton: View {
    @State private var isConfirming = false

    let isDisabled: Bool
    let onConfirm: () -> Void

    var body: some View {
        Button(action: confirm) {
            Text("clients.edit.delete")
                .font(.elmsSans(.semiBold, ClientsMetrics.Size.deleteTitle))
                .foregroundStyle(Color.destructive)
                .frame(maxWidth: .infinity, minHeight: ClientsMetrics.Size.deleteMinHeight)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .alert("clients.delete.confirm.title", isPresented: $isConfirming) {
            Button("clients.delete.confirm.action", role: .destructive, action: onConfirm)

            Button("common.action.cancel", role: .cancel) {}
        } message: {
            Text("clients.delete.confirm.message")
        }
    }

    private func confirm() {
        isConfirming = true
    }
}

#if DEBUG
#Preview {
    ClientDeleteButton(isDisabled: false, onConfirm: {})
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.background)
}
#endif
