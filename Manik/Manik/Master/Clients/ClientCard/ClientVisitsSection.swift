import SwiftUI

private struct ClientVisitRow: View {
    let visit: ClientVisitItem

    var body: some View {
        HStack(spacing: ClientsMetrics.Spacing.rowContentSpacing) {
            VStack(alignment: .leading, spacing: ClientsMetrics.Spacing.visitTextSpacing) {
                Text(verbatim: visit.dateText)
                    .font(.elmsSans(.semiBold, ClientsMetrics.Size.visitDate))
                    .foregroundStyle(Color.ink)

                Text(verbatim: visit.serviceText)
                    .font(.elmsSans(.regular, ClientsMetrics.Size.visitService))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)

            Text(verbatim: visit.timeText)
                .font(.elmsSans(.medium, ClientsMetrics.Size.visitTime))
                .foregroundStyle(Color.ink)
        }
        .padding(.horizontal, ClientsMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, ClientsMetrics.Spacing.rowVerticalPadding)
        .accessibilityElement(children: .combine)
    }
}

struct ClientVisitsSection: View {
    let titleKey: LocalizedStringKey
    let visits: [ClientVisitItem]

    var body: some View {
        VStack(alignment: .leading, spacing: ClientsMetrics.Spacing.rowSpacing) {
            SectionLabel(titleKey: titleKey)
                .padding(.horizontal, ClientsMetrics.Spacing.sectionLabelInset)

            if visits.isEmpty {
                Text("clients.history.empty")
                    .font(.elmsSans(.regular, ClientsMetrics.Size.cardDetails))
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ClientsMetrics.Spacing.noContactsPadding)
            } else {
                VStack(spacing: 0) {
                    ForEach(visits) { visit in
                        if visit.id != visits.first?.id {
                            Color.hairline
                                .frame(height: ClientsMetrics.Size.dividerHeight)
                        }

                        ClientVisitRow(visit: visit)
                    }
                }
                .cardSurface(padding: 0, cornerRadius: ClientsMetrics.Size.rowCornerRadius)
            }
        }
    }
}
