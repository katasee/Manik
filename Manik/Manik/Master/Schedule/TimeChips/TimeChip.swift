import SwiftUI

struct TimeChip: View {
    let time: TimeChipItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ScheduleMetrics.Spacing.chipGlyphSpacing) {
                Text(verbatim: time.text)
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.chipTime))
                    .lineLimit(1)
                    .minimumScaleFactor(ScheduleMetrics.Size.chipTextScale)

                if time.isCustom {
                    Image(systemName: "xmark")
                        .font(.elmsSans(.bold, ScheduleMetrics.Size.chipGlyph))
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(time.isSelected ? Color.onPrimary : Color.ink)
            .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.chipHeight)
            .selectableSurface(isSelected: time.isSelected, in: .capsule)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(time.isSelected ? .isSelected : [])
        .accessibilityHint(time.isCustom ? Text("schedule.fill.action.removeTime") : Text(verbatim: ""))
    }
}
