import SwiftUI

struct BookingHeader: View {
    let clientName: String
    let nearestSlot: BookingSlot?
    let topInset: CGFloat

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
        .padding(.horizontal, BookingMetrics.Spacing.headerHorizontalPadding)
        .padding(.top, BookingMetrics.Spacing.headerPadding + topInset)
        .padding(.bottom, BookingMetrics.Spacing.headerPadding)
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
        let radius = BookingMetrics.Size.headerCornerRadius

        return GeometryReader { proxy in
            let stretch = max(0, proxy.frame(in: .scrollView).minY)

            Color.ink
                .overlay(alignment: .topTrailing) { bubble(stretch: stretch) }
                .clipShape(.rect(bottomLeadingRadius: radius, bottomTrailingRadius: radius))
                .frame(height: proxy.size.height + stretch)
                .offset(y: -stretch)
        }
    }

    private func bubble(stretch: CGFloat) -> some View {
        let diameter = BookingMetrics.Size.headerBubble

        return Ellipse()
            .fill(Color.background.opacity(BookingMetrics.Opacity.headerBubble))
            .frame(width: diameter, height: diameter + stretch)
            .offset(x: diameter / 3, y: -diameter / 3)
    }
}

#if DEBUG
#Preview("З найближчим вікном") {
    ScrollView {
        BookingHeader(
            clientName: "Олена",
            nearestSlot: BookingSlot(
                id: "b1",
                date: DateFormat.date.string(from: BookingPreviewData.reference),
                startTime: "10:00"
            ),
            topInset: 0
        )
    }
    .background(Color.background)
}

#Preview("Без вікон") {
    ScrollView {
        BookingHeader(
            clientName: "Олена",
            nearestSlot: nil,
            topInset: 0
        )
    }
    .background(Color.background)
}
#endif
