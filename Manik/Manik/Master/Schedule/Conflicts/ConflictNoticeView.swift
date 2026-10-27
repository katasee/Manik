import SwiftUI

struct ConflictNoticeView: View {
    let notice: ConflictNotice

    var body: some View {
        Group {
            switch notice {
            case .overlap(let entry):
                ConflictLine(text: entry.text, mark: notice.mark)
                    .padding(.vertical, ScheduleMetrics.Spacing.conflictPadding)
            case .close(let entries) where entries.count > 1:
                ConflictCloseList(entries: entries, mark: notice.mark)
            case .close(let entries):
                ForEach(entries) { entry in
                    ConflictLine(text: entry.text, mark: notice.mark)
                        .padding(.vertical, ScheduleMetrics.Spacing.conflictPadding)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ScheduleMetrics.Spacing.conflictPadding)
        .background(notice.mark.softColor, in: .rect(cornerRadius: ScheduleMetrics.Size.conflictCornerRadius))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ConflictNoticeView(notice: SchedulePreviewData.overlapNotice)
        ConflictNoticeView(notice: SchedulePreviewData.closeNotice)
        ConflictNoticeView(notice: SchedulePreviewData.closeNotices)
    }
    .padding()
    .background(Color.card)
}
#endif
