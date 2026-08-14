import SwiftUI

struct ServiceOfferCard: View {
    private static let maxChips = 3

    let offer: ServiceOffer

    private var chips: [BookingSlot] {
        Array(offer.nearestDaySlots.prefix(Self.maxChips))
    }

    var body: some View {
        ZStack {
            NavigationLink(value: offer) {
                Color.clear
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("booking.card.allDates")

            VStack(
                alignment: .leading,
                spacing: BookingMetrics.Spacing.cardContentSpacing
            ) {
                titleRow
                nearestLabel
                slotRow
            }
            .padding(BookingMetrics.Spacing.cardPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.surface,
            in: .rect(cornerRadius: BookingMetrics.Size.cardCornerRadius)
        )
    }

    private var titleRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(offer.service.name)
                .font(.elmsSans(.medium, 18))
                .foregroundStyle(Color.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: BookingMetrics.Spacing.cardContentSpacing)

            Text(ServiceFormat.price(offer.service.price))
                .font(.elmsSans(.bold, 18))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .allowsHitTesting(false)
    }

    private var slotRow: some View {
        HStack(spacing: BookingMetrics.Spacing.chipSpacing) {
            ForEach(chips) { slot in
                NavigationLink(value: slot) {
                    SlotChip(slot: slot)
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: BookingMetrics.Spacing.chipSpacing)

            chevron
        }
    }

    @ViewBuilder
    private var nearestLabel: some View {
        if let nearest = offer.nearestSlot {
            HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
                Text("booking.card.nearest")
                Text(verbatim: "·")
                Text(verbatim: nearest.dayLabel)
            }
            .font(.elmsSans(.medium, 12))
            .textCase(.uppercase)
            .tracking(BookingMetrics.Tracking.sectionLabel)
            .foregroundStyle(Color.textSecondary)
            .allowsHitTesting(false)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.elmsSans(.bold, BookingMetrics.Size.chevron))
            .foregroundStyle(Color.background)
            .frame(
                width: BookingMetrics.Size.chevronButton,
                height: BookingMetrics.Size.chevronButton
            )
            .background(Color.ink, in: .circle)
            .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview {
    let offers = BookingAvailability.offers(
        blocks: BookingPreviewData.blocks,
        services: BookingPreviewData.services,
        now: BookingPreviewData.reference
    )

    return NavigationStack {
        VStack(spacing: BookingMetrics.Spacing.listSpacing) {
            ForEach(offers) { offer in
                ServiceOfferCard(offer: offer)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
    }
}
#endif
