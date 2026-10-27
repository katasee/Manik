import SwiftUI

struct ConflictNearList: View {
    let entries: [ConflictEntry]
    let mark: ConflictMark

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.conflictLineSpacing) {
            Button(action: toggle) {
                HStack(spacing: ScheduleMetrics.Spacing.conflictGlyphSpacing) {
                    ConflictGlyph(mark: mark)

                    Text("schedule.conflict.nearCount \(entries.count)")
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
                    ConflictEntryList(entries: entries, mark: mark)

                    ScrollView {
                        ConflictEntryList(entries: entries, mark: mark)
                    }
                    .scrollIndicators(.hidden)
                }
                .frame(maxHeight: ScheduleMetrics.Size.conflictListMaxHeight)
                .padding(.bottom, ScheduleMetrics.Spacing.conflictPadding)
            }
        }
    }

    private func toggle() {
        withAnimation {
            isExpanded.toggle()
        }
    }
}

#if DEBUG
#Preview {
    ConflictNearList(entries: SchedulePreviewData.nearEntries, mark: ConflictMark(.near))
        .padding()
        .background(Color.card)
}
#endif
