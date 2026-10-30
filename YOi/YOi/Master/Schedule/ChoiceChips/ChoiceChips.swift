import SwiftUI

struct ChoiceChips: View {
    let chips: [ChoiceChip]
    let onToggle: (String) -> Void

    private let columns = [
        GridItem(
            .adaptive(minimum: ScheduleMetrics.Size.choiceChipMinWidth),
            spacing: ScheduleMetrics.Spacing.chipSpacing
        )
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: ScheduleMetrics.Spacing.chipSpacing) {
            ForEach(chips) { chip in
                Button {
                    onToggle(chip.id)
                } label: {
                    Text(verbatim: chip.title)
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.chipTime))
                        .lineLimit(1)
                        .minimumScaleFactor(ScheduleMetrics.Size.chipTextScale)
                        .foregroundStyle(chip.isSelected ? Color.onPrimary : Color.ink)
                        .padding(.horizontal, ScheduleMetrics.Spacing.bookRowPadding)
                        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.chipHeight)
                        .selectableSurface(isSelected: chip.isSelected, in: .capsule)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(chip.isSelected ? .isSelected : [])
            }
        }
        .glassEffectGroup()
    }
}

#if DEBUG
#Preview {
    ChoiceChips(chips: SchedulePreviewData.serviceChips, onToggle: { _ in })
        .padding()
        .background(Color.card)
}
#endif
