import SwiftUI

struct BlockDetailRow: View {
    let labelKey: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Detail.rowSpacing) {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 13))
                .foregroundStyle(Color.textSecondary)

            Text(value)
                .font(.elmsSans(.medium, 15))
                .foregroundStyle(Color.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    BlockDetailRow(labelKey: "schedule.detail.services", value: "Манікюр, Педикюр")
        .padding()
        .background(Color.background)
}
