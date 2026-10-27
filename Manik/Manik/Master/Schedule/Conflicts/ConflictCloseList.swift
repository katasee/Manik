import SwiftUI

struct ConflictCloseList: View {
    let entries: [ConflictEntry]
    let mark: ConflictMark

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.conflictLineSpacing) {
            Button(action: toggle) {
                HStack(spacing: ScheduleMetrics.Spacing.conflictGlyphSpacing) {
                    Image(systemName: mark.systemImage)
                        .font(.elmsSans(.medium, ScheduleMetrics.Size.conflictGlyph))
                        .accessibilityHidden(true)

                    Text("schedule.conflict.closeCount \(entries.count)")
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.conflictText))

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.conflictGlyph))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .accessibilityHidden(true)
                }
                .foregroundStyle(mark.color)
                .frame(minHeight: ScheduleMetrics.Size.conflictTapHeight)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            if isExpanded {
                ViewThatFits(in: .vertical) {
                    lines

                    ScrollView {
                        lines
                    }
                    .scrollIndicators(.hidden)
                }
                .frame(maxHeight: ScheduleMetrics.Size.conflictListMaxHeight)
                .padding(.bottom, ScheduleMetrics.Spacing.conflictPadding)
            }
        }
    }

    private var lines: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.conflictLineSpacing) {
            ForEach(entries) { entry in
                ConflictLine(text: entry.text, mark: mark)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggle() {
        withAnimation {
            isExpanded.toggle()
        }
    }
}

#if DEBUG
#Preview {
    ConflictCloseList(entries: SchedulePreviewData.closeEntries, mark: ConflictMark(.close))
        .padding()
        .background(Color.card)
}
#endif
