import SwiftUI

struct ConflictGlyph: View {
    let mark: ConflictMark

    var body: some View {
        Image(systemName: mark.systemImage)
            .font(.elmsSans(.medium, ScheduleMetrics.Size.conflictGlyph))
            .foregroundStyle(mark.color)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 12) {
        ConflictGlyph(mark: ConflictMark(.close))
        ConflictGlyph(mark: ConflictMark(.overlap))
    }
    .padding()
    .background(Color.card)
}
#endif
