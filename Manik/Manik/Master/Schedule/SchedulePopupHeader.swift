import SwiftUI

struct SchedulePopupHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.bookTitleSpacing) {
            Text(verbatim: title)
                .font(.elmsSans(.bold, ScheduleMetrics.Size.bookTitle))
                .foregroundStyle(Color.ink)
                .accessibilityAddTraits(.isHeader)

            Text(verbatim: subtitle)
                .font(.elmsSans(.regular, ScheduleMetrics.Size.bookSubtitle))
                .foregroundStyle(Color.textSecondary)
        }
    }
}

#if DEBUG
#Preview {
    SchedulePopupHeader(title: String(localized: "schedule.book.title"), subtitle: SchedulePreviewData.bookClient.subtitle)
        .padding()
        .background(Color.card)
}
#endif
