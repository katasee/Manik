import SwiftUI

struct BookingConfirmView: View {
    @Environment(\.dismiss) private var dismiss

    let slot: BookingSlot

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack {
            Text("booking.confirm.title")
                .font(.elmsSans(.bold, 22))
                .foregroundStyle(Color.ink)

            HStack {
                backButton

                Spacer()
            }
        }
        .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
    }

    private var backButton: some View {
        Button("common.action.back", systemImage: "chevron.left", action: goBack)
            .labelStyle(.iconOnly)
            .font(.elmsSans(.regular, BookingMetrics.Size.backIcon))
            .foregroundStyle(Color.ink)
            .frame(
                minWidth: BookingMetrics.Size.backTapTarget,
                minHeight: BookingMetrics.Size.backTapTarget,
                alignment: .leading
            )
            .contentShape(.rect)
    }

    private func goBack() {
        dismiss()
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
        BookingConfirmView(slot: offers[0].nearestDaySlots[0])
    }
}
#endif
