import SwiftUI

struct SlotChip: View {
    let slot: BookingSlot
    var isSelected = false

    var body: some View {
        Text(slot.timeLabel)
            .font(.elmsSans(.bold, 15))
            .foregroundStyle(isSelected ? Color.onPrimary : Color.ink)
            .lineLimit(1)
            .padding(.horizontal, BookingMetrics.Spacing.chipPadding)
            .frame(
                minWidth: BookingMetrics.Size.chipMinWidth,
                minHeight: BookingMetrics.Size.chipHeight
            )
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.primaryFill)
                        .brandShadow()
                } else {
                    Color.clear
                        .raisedSurface(.capsule)
                }
            }
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
    .background(Color.background)
}
#endif
