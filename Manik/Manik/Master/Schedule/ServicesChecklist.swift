import SwiftUI

struct ServicesChecklist: View {
    let services: [Service]
    let isSelected: (Service) -> Bool
    let onToggle: (Service) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(services) { service in
                Button {
                    onToggle(service)
                } label: {
                    HStack {
                        Text(service.name)
                        Spacer()
                        Image(systemName: isSelected(service) ? "checkmark.square.fill" : "square")
                    }
                    .frame(minHeight: 44)
                }
            }
        }
        .font(.elmsSans(.regular, 15))
        .foregroundStyle(Color.ink)
        .buttonStyle(.plain)
    }
}

#Preview {
    ServicesChecklist(
        services: SchedulePreviewData.services,
        isSelected: { _ in false },
        onToggle: { _ in }
    )
    .padding()
    .background(Color.background)
}
