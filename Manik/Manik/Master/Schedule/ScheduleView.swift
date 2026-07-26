import SwiftUI

struct ScheduleView: View {
    private let serviceRepository: ServiceRepository

    @State private var selectedDate = Date.now
    @State private var services: [Service] = []
    @State private var creatingBlockContext: CreateBlockContext?

    init(serviceRepository: ServiceRepository = FirestoreServiceRepository()) {
        self.serviceRepository = serviceRepository
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                title
                date
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ScheduleMetrics.Spacing.timelineHorizontalPadding)

            WeekDayStrip(selectedDate: $selectedDate)
                .padding(.vertical, 12)

            Color.surface
                .frame(height: 1)

            HourlyTimelineView { hour in
                creatingBlockContext = CreateBlockContext(date: selectedDate, startHour: hour)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            for await updatedServices in serviceRepository.observeServices() {
                services = updatedServices
            }
        }
        .fullScreenCover(item: $creatingBlockContext) { context in
            AddNewSlotBlock(
                date: context.date,
                startHour: context.startHour,
                services: services,
                onDismiss: { creatingBlockContext = nil }
            )
            .presentationBackground(.clear)
        }
    }

    private var title: some View {
        Text("schedule.title")
            .font(.elmsSans(.bold, 28))
            .foregroundStyle(Color.ink)
    }

    private var date: some View {
        Text(DateFormat.monthYear.string(from: selectedDate).capitalized)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.textSecondary)
    }
}

#Preview {
    ScheduleView(serviceRepository: FakeServiceRepository(services: SchedulePreviewData.services))
}
