import SwiftUI

struct RequestCard: View {
    let request: BookingRequest
    let isBusy: Bool
    let runningAction: BlockAction?
    let perform: (BlockAction) async -> Bool

    private static let actions: [BlockAction] = [.decline, .confirm]

    var body: some View {
        VStack(alignment: .leading, spacing: RequestsMetrics.Spacing.cardContentSpacing) {
            clientRow
            serviceRow
            scheduleRow
            actionsRow
        }
        .padding([.vertical, .trailing], RequestsMetrics.Spacing.cardPadding)
        .padding(.leading, RequestsMetrics.Spacing.cardLeadingPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.surface,
            in: .rect(cornerRadius: RequestsMetrics.Size.cardCornerRadius)
        )
        .overlay(alignment: .leading) { accent }
    }

    private var clientRow: some View {
        Text(verbatim: request.clientName)
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)
            .lineLimit(1)
    }

    private var serviceRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: RequestsMetrics.Spacing.inlineSpacing) {
            Text(verbatim: request.serviceName)
                .font(.elmsSans(.medium, 16))
                .foregroundStyle(Color.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: RequestsMetrics.Spacing.inlineSpacing)

            priceText
        }
    }

    @ViewBuilder
    private var priceText: some View {
        if let priceLabel = request.priceLabel {
            Text(verbatim: priceLabel)
                .font(.elmsSans(.bold, 16))
                .foregroundStyle(Color.ink)
                .layoutPriority(1)
        }
    }

    private var scheduleRow: some View {
        HStack(spacing: RequestsMetrics.Spacing.inlineSpacing) {
            Text(verbatim: request.dayLabel)
            Text(verbatim: "·")
            Text(verbatim: request.timeRangeLabel)
        }
        .font(.elmsSans(.medium, 13))
        .foregroundStyle(Color.textSecondary)
    }

    private var actionsRow: some View {
        HStack(spacing: RequestsMetrics.Spacing.actionsSpacing) {
            ForEach(Self.actions) { action in
                BlockActionButton(
                    action: action,
                    style: .card,
                    isLoading: runningAction == action,
                    isEnabled: isBusy == false,
                    perform: perform,
                    onSuccess: {}
                )
            }
        }
        .padding(.top, RequestsMetrics.Spacing.actionsTopPadding)
    }

    private var accent: some View {
        Capsule()
            .fill(BlockStatus.pending.accentColor)
            .frame(width: RequestsMetrics.Size.accentWidth)
            .padding([.vertical, .leading], RequestsMetrics.Size.accentInset)
    }
}

#if DEBUG
#Preview {
    let requests = RequestsList.requests(
        blocks: RequestsPreviewData.blocks,
        services: RequestsPreviewData.services,
        clientNames: [
            "client-olena": "Олена Ковальчук",
            "client-maria": "Марія Ткаченко",
            "client-sofia": "Софія Бондар"
        ],
        unreadableClientIds: [],
        now: RequestsPreviewData.reference
    )

    return VStack(spacing: RequestsMetrics.Spacing.listSpacing) {
        ForEach(Array(requests.enumerated()), id: \.element.id) { index, request in
            RequestCard(
                request: request,
                isBusy: index > 0,
                runningAction: index == 1 ? .confirm : nil,
                perform: { _ in true }
            )
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.background)
}
#endif
