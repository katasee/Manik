import SwiftUI

struct ConflictEntryList: View {
    let entries: [ConflictEntry]
    let mark: ConflictMark

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.conflictLineSpacing) {
            ForEach(entries) { entry in
                ConflictLine(text: entry.text, mark: mark)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    ConflictEntryList(entries: SchedulePreviewData.nearEntries, mark: ConflictMark(.near))
        .padding()
        .background(Color.card)
}
#endif
