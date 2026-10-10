import SwiftUI

struct ClientRow: View {
    let item: ClientItem

    var body: some View {
        HStack(spacing: ClientsMetrics.Spacing.rowContentSpacing) {
            ClientAvatar(initial: item.initial, size: ClientsMetrics.Size.rowAvatar)

            Text(verbatim: item.title)
                .font(.elmsSans(.semiBold, ClientsMetrics.Size.rowName))
                .foregroundStyle(Color.ink)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, ClientsMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, ClientsMetrics.Spacing.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: 0, cornerRadius: ClientsMetrics.Size.rowCornerRadius)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ClientsMetrics.Spacing.rowSpacing) {
        ForEach(ClientsPreviewData.clients.map(ClientItem.init)) { item in
            ClientRow(item: item)
        }
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
#endif
