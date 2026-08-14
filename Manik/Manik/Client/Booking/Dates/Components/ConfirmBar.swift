import SwiftUI

struct ConfirmBar: View {
    let serviceName: String
    let slotLabel: String
    let priceLabel: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: BookingMetrics.Spacing.cardContentSpacing) {
            VStack(alignment: .leading, spacing: BookingMetrics.Spacing.footerSpacing) {
                Text(verbatim: serviceName)
                    .font(.elmsSans(.medium, 15))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)

                Text(verbatim: "\(slotLabel) · \(priceLabel)")
                    .font(.elmsSans(.regular, 13))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: BookingMetrics.Spacing.pillSpacing)

            Button(action: action) {
                Text("booking.action.continue")
                    .font(.elmsSans(.bold, 15))
                    .foregroundStyle(Color.background)
                    .padding(.horizontal, BookingMetrics.Spacing.headerPadding)
                    .frame(minHeight: BookingMetrics.Size.chipHeight)
                    .background(
                        Color.ink,
                        in: .rect(cornerRadius: BookingMetrics.Size.chipCornerRadius)
                    )
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .padding(BookingMetrics.Spacing.cardPadding)
        .background(
            Color.surface,
            in: .rect(cornerRadius: BookingMetrics.Size.cardCornerRadius)
        )
    }
}

#if DEBUG
#Preview {
    ConfirmBar(
        serviceName: "Манікюр + гель-лак",
        slotLabel: "12 серп, 12:30",
        priceLabel: "750 zł",
        action: {}
    )
    .padding()
    .background(Color.background)
}
#endif
