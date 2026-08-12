import SwiftUI

struct BookingHeader: View {
    let clientName: String
    let nearestSlot: BookingSlot?

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BookingMetrics.Spacing.headerContentSpacing
        ) {
            greeting
            title
            nearestPill
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BookingMetrics.Spacing.headerPadding)
        .background { headerBackground }
    }

    private var greeting: some View {
        Text(String(format: String(localized: "booking.greeting"), clientName))
            .font(.elmsSans(.regular, 15))
            .foregroundStyle(Color.background.opacity(BookingMetrics.Opacity.headerGreeting))
    }

    private var title: some View {
        Text("booking.title")
            .font(.elmsSans(.bold, 30))
            .foregroundStyle(Color.background)
    }

    @ViewBuilder
    private var nearestPill: some View {
        if let nearestSlot {
            HStack(spacing: BookingMetrics.Spacing.pillSpacing) {
                Circle()
                    .fill(Color.freeSlot)
                    .frame(
                        width: BookingMetrics.Size.pillDot,
                        height: BookingMetrics.Size.pillDot
                    )

                Text(
                    String(
                        format: String(localized: "booking.nearestWindow"),
                        "\(nearestSlot.shortDayLabel), \(nearestSlot.timeLabel)"
                    )
                )
                .font(.elmsSans(.bold, 14))
                .foregroundStyle(Color.background)
            }
            .padding(.horizontal, BookingMetrics.Spacing.pillPadding)
            .padding(.vertical, BookingMetrics.Spacing.pillSpacing)
            .background(
                Color.background.opacity(BookingMetrics.Opacity.headerPill),
                in: .capsule
            )
        }
    }

    private var headerBackground: some View {
        Color.ink
            .overlay(alignment: .topTrailing) { bubble }
            .clipShape(.rect(cornerRadius: BookingMetrics.Size.headerCornerRadius))
    }

    private var bubble: some View {
        Circle()
            .fill(Color.background.opacity(BookingMetrics.Opacity.headerBubble))
            .frame(
                width: BookingMetrics.Size.headerBubble,
                height: BookingMetrics.Size.headerBubble
            )
            .offset(
                x: BookingMetrics.Size.headerBubble / 3,
                y: -BookingMetrics.Size.headerBubble / 3
            )
    }
}

#if DEBUG
#Preview("З найближчим вікном") {
    BookingHeader(
        clientName: "Олена",
        nearestSlot: BookingSlot(
            id: "b1",
            date: DateFormat.date.string(from: BookingPreviewData.reference),
            startTime: "10:00"
        )
    )
    .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
    .background(Color.background)
}

#Preview("Без вікон") {
    BookingHeader(clientName: "Олена", nearestSlot: nil)
        .padding(.horizontal, BookingMetrics.Spacing.horizontalPadding)
        .background(Color.background)
}
#endif
