import SwiftUI

struct CreateBlockFieldRow<Control: View>: View {
    let labelKey: LocalizedStringKey
    @ViewBuilder let control: Control

    var body: some View {
        HStack {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)
            Spacer()
            control
        }
    }
}

#Preview {
    CreateBlockFieldRow(labelKey: "schedule.createSlot.dateLabel") {
        DatePicker("", selection: .constant(Date.now), displayedComponents: .date)
            .labelsHidden()
    }
    .padding()
    .background(Color.background)
}
