import SwiftUI

struct ConflictNoticeView: View {
    let notice: ConflictNotice

    var body: some View {
        Group {
            switch notice {
            case .overlap(let entry):
                ConflictLine(text: entry.text, mark: notice.mark)
                    .padding(.vertical, ScheduleMetrics.Spacing.conflictPadding)
            case .near(let entries) where entries.count > 1:
                ConflictNearList(entries: entries, mark: notice.mark)
            case .near(let entries):
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
        ConflictNoticeView(notice: SchedulePreviewData.nearNotice)
        ConflictNoticeView(notice: SchedulePreviewData.nearNotices)
    }
    .padding()
    .background(Color.card)
}
#endif
