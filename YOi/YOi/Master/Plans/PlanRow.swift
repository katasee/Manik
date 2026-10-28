import SwiftUI

struct PlanRow: View {
    let template: EventTemplate
    let onToggleActive: () -> Void

    var body: some View {
        HStack(spacing: PlansMetrics.Spacing.rowContentSpacing) {
            toggle
            name

            Spacer(minLength: 0)
        }
        .padding(.horizontal, PlansMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, PlansMetrics.Spacing.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: 0, cornerRadius: PlansMetrics.Size.rowCornerRadius)
    }

    private var toggle: some View {
        Button(action: onToggleActive) {
            PlanEmojiTile(emoji: template.emoji, isActive: template.isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("plans.row.toggle")
        .accessibilityValue(template.isActive ? "plans.row.active" : "plans.row.inactive")
    }

    private var name: some View {
        Text(template.name)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.ink)
            .lineLimit(2)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: PlansMetrics.Spacing.rowSpacing) {
        ForEach(PlansPreviewData.templates) { template in
            PlanRow(template: template, onToggleActive: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
