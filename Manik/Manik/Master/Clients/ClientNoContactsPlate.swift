import SwiftUI

struct ClientNoContactsPlate: View {
    var body: some View {
        Text("clients.card.noContacts")
            .font(.elmsSans(.regular, ClientsMetrics.Size.cardDetails))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity)
            .cardSurface(padding: ClientsMetrics.Spacing.noContactsPadding, cornerRadius: ClientsMetrics.Size.noContactsCornerRadius)
    }
}

#if DEBUG
#Preview {
    ClientNoContactsPlate()
        .padding()
        .background(Color.background)
}
#endif
