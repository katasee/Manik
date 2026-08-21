import SwiftUI

struct MyBookingCard: View {
    let booking: MyBooking
    let onCancel: (CancelBookingContext) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.cardContentSpacing) {
            titleRow
            scheduleRow
            footerRow
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
    private var footerRow: some View {
        if booking.priceLabel != nil || booking.cancelId != nil {
            HStack(spacing: MyBookingsMetrics.Spacing.inlineSpacing) {
                priceText

                Spacer(minLength: MyBookingsMetrics.Spacing.inlineSpacing)

                cancelButton
            }
        }
    }

    @ViewBuilder
    private var priceText: some View {
        if let priceLabel = booking.priceLabel {
            Text(verbatim: priceLabel)
                .font(.elmsSans(.bold, 16))
                .foregroundStyle(Color.ink)
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        if let cancelId = booking.cancelId {
            Button {
                onCancel(context(cancelId: cancelId))
            } label: {
                Text("myBookings.action.cancel")
                    .font(.elmsSans(.semiBold, 14))
                    .frame(minHeight: MyBookingsMetrics.Size.cancelTapTarget)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.destructive)
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

    private func context(cancelId: String) -> CancelBookingContext {
        CancelBookingContext(
            id: cancelId,
            serviceName: booking.serviceName,
            dayLabel: booking.dayLabel,
            timeRangeLabel: booking.timeRangeLabel
        )
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
                MyBookingCard(booking: booking, onCancel: { _ in })
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.background)
}
#endif
