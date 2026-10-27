import SwiftUI

struct ConflictLine: View {
    let text: String
    let mark: ConflictMark

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ScheduleMetrics.Spacing.conflictGlyphSpacing) {
            ConflictGlyph(mark: mark)

            Text(verbatim: text)
                .font(.elmsSans(.medium, ScheduleMetrics.Size.conflictText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(mark.color)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ConflictLine(text: "5.10 о 10:00 · 🥊 Бокс", mark: ConflictMark(.overlap))
        ConflictLine(text: "5.10 о 9:00 · 🦷 Стоматолог-ортодонт о 10:00", mark: ConflictMark(.near))
    }
    .padding()
    .background(Color.card)
}
#endif
