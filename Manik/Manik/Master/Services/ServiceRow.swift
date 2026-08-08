import SwiftUI

struct ServiceRow: View {
    let service: Service
    let onToggleActive: () -> Void

    var body: some View {
        HStack(spacing: ServicesMetrics.Spacing.rowContentSpacing) {
            icon
            details

            Spacer(minLength: 0)

            price
        }
        .padding(.horizontal, ServicesMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, ServicesMetrics.Spacing.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.fieldBackground,
            in: .rect(cornerRadius: ServicesMetrics.Size.rowCornerRadius)
        )
    }

    private var icon: some View {
        Button(action: onToggleActive) {
            Image(systemName: service.isOffered ? "star.fill" : "star")
                .font(.elmsSans(.regular, ServicesMetrics.Size.rowIconGlyph))
                .foregroundStyle(Color.ink)
                .frame(
                    width: ServicesMetrics.Size.rowIcon,
                    height: ServicesMetrics.Size.rowIcon
                )
                .overlay {
                    Circle()
                        .strokeBorder(Color.surface, lineWidth: ServicesMetrics.Size.rowIconBorder)
                }
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
    }

    private var details: some View {
        Text(service.name)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.ink)
            .lineLimit(2)
    }

    private var price: some View {
        Text(ServiceFormat.price(service.price))
            .font(.elmsSans(.bold, 17))
            .foregroundStyle(Color.ink)
            .lineLimit(1)
            .layoutPriority(1)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
        ForEach(ServicesPreviewData.services) { service in
            ServiceRow(service: service, onToggleActive: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
