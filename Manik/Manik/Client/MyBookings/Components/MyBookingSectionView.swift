import SwiftUI

struct MyBookingSectionView: View {
    let section: MyBookingSection

    var body: some View {
        VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.listSpacing) {
            Text(titleKey)
                .font(.elmsSans(.medium, 12))
                .textCase(.uppercase)
                .tracking(MyBookingsMetrics.Tracking.sectionLabel)
                .foregroundStyle(Color.textSecondary)

            ForEach(section.bookings) { booking in
                MyBookingCard(booking: booking)
            }
        }
    }

    private var titleKey: LocalizedStringKey {
        switch section.kind {
        case .upcoming: "myBookings.section.upcoming"
        case .past: "myBookings.section.past"
        }
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

    return ScrollView {
        VStack(alignment: .leading, spacing: MyBookingsMetrics.Spacing.sectionSpacing) {
            ForEach(sections) { section in
                MyBookingSectionView(section: section)
            }
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
#endif
