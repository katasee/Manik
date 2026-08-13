import SwiftUI

struct SlotChip: View {
    let slot: BookingSlot
    var isSelected = false

    var body: some View {
        Text(slot.timeLabel)
            .font(.elmsSans(.bold, 15))
            .foregroundStyle(isSelected ? Color.background : Color.ink)
            .lineLimit(1)
            .padding(.horizontal, BookingMetrics.Spacing.chipPadding)
            .frame(
                minWidth: BookingMetrics.Size.chipMinWidth,
                minHeight: BookingMetrics.Size.chipHeight
            )
            .background {
                Capsule()
                    .fill(isSelected ? Color.ink : Color.background)
                    .stroke(borderColor, lineWidth: BookingMetrics.Size.chipBorderWidth)
            }
    }

    private var borderColor: Color {
        isSelected ? Color.ink : Color.ink.opacity(BookingMetrics.Opacity.chipBorder)
    }
}

#if DEBUG
#Preview {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return HStack(spacing: BookingMetrics.Spacing.chipSpacing) {
        ForEach(offers[0].nearestDaySlots) { slot in
            SlotChip(slot: slot)
        }
    }
    .padding()
    .background(Color.surface)
}
#endif
