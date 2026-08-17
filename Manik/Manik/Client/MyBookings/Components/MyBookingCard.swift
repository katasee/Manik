import SwiftUI

struct MyBookingCard: View {
    let booking: MyBooking

    var body: some View {
        VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.cardContentSpacing) {
            titleRow
            scheduleRow
            priceRow
        }
        .padding([.vertical, .trailing], MyBookingsMetrics.Spacing.cardPadding)
        .padding(.leading, MyBookingsMetrics.Spacing.cardLeadingPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.surface,
            in: .rect(cornerRadius: MyBookingsMetrics.Size.cardCornerRadius)
        )
        .overlay(alignment: .leading) { accent }
    }

    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: MyBookingsMetrics.Spacing.inlineSpacing) {
            Text(booking.serviceName)
                .font(.elmsSans(.medium, 18))
                .foregroundStyle(Color.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: MyBookingsMetrics.Spacing.inlineSpacing)

            if booking.isPast == false {
                BlockStatusPill(status: booking.status)
                    .layoutPriority(1)
            }
        }
    }

    private var scheduleRow: some View {
        HStack(spacing: MyBookingsMetrics.Spacing.inlineSpacing) {
            Text(verbatim: booking.dayLabel)
            Text(verbatim: "·")
            Text(verbatim: booking.timeRangeLabel)
        }
        .font(.elmsSans(.medium, 13))
        .foregroundStyle(Color.textSecondary)
    }

    @ViewBuilder
    private var priceRow: some View {
        if let priceLabel = booking.priceLabel {
            Text(verbatim: priceLabel)
                .font(.elmsSans(.bold, 16))
                .foregroundStyle(Color.ink)
        }
    }

    private var accent: some View {
        Capsule()
            .fill(accentStyle)
            .frame(width: MyBookingsMetrics.Size.accentWidth)
            .padding([.vertical, .leading], MyBookingsMetrics.Size.accentInset)
    }

    private var accentStyle: Color {
        booking.isPast
            ? Color.textSecondary.opacity(MyBookingsMetrics.Opacity.pastAccent)
            : booking.status.accentColor
    }
}

#if DEBUG
#Preview {
    let sections = MyBookingsList.sections(
        blocks: MyBookingsPreviewData.blocks,
        services: MyBookingsPreviewData.services,
        clientId: MyBookingsPreviewData.clientId,
        now: MyBookingsPreviewData.reference
    )

    return VStack(spacing: MyBookingsMetrics.Spacing.listSpacing) {
        ForEach(sections) { section in
            ForEach(section.bookings) { booking in
                MyBookingCard(booking: booking)
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.background)
}
#endif
