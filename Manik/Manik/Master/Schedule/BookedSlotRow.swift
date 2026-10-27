import SwiftUI

struct BookedSlotRow: View {
    let item: SlotItem
    let booking: SlotBookingItem

    var body: some View {
        HStack(spacing: 0) {
            Text(verbatim: item.timeText)
                .font(.elmsSans(.semiBold, ScheduleMetrics.Size.rowTime))
                .foregroundStyle(Color.ink)
                .frame(width: ScheduleMetrics.Size.rowTimeWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.rowLineSpacing) {
                Text(verbatim: booking.clientName)
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.rowName))
                    .foregroundStyle(Color.ink)

                Text(verbatim: booking.serviceText)
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.rowService))
                    .foregroundStyle(Color.textSecondary)
            }
            .lineLimit(1)

            Spacer(minLength: 0)

            if let mark {
                ConflictGlyph(mark: mark)
            }
        }
        .padding(.horizontal, ScheduleMetrics.Spacing.rowHorizontalPadding)
        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.bookedRowHeight)
        .cardSurface(padding: 0, cornerRadius: ScheduleMetrics.Size.rowCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: ScheduleMetrics.Size.rowCornerRadius)
                .strokeBorder(outlineColor, lineWidth: ScheduleMetrics.Size.rowBorderWidth)
        }
        .opacity(item.isPast ? ScheduleMetrics.Size.pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }

    private var mark: ConflictMark? {
        item.conflict.map(ConflictMark.init)
    }

    private var outlineColor: Color {
        if let mark {
            mark.color
        } else {
            .clear
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
        ForEach(SchedulePreviewData.items) { item in
            if let booking = item.booking {
                BookedSlotRow(item: item, booking: booking)
            }
        }
    }
    .padding()
    .background(Color.background)
}
#endif
