import Foundation
import Observation

@MainActor
@Observable
final class CreateBlockViewModel {
    var date: Date
    var startTime: Date
    var endTime: Date
    var selectedServiceIds: Set<String> = []
    var errorMessage: String?
    var isSaving = false

    let services: [Service]

    private let blockRepository: BlockRepository

    init(
        date: Date,
        startHour: Int,
        services: [Service],
        blockRepository: BlockRepository = FirestoreBlockRepository()
    ) {
        self.date = date
        self.services = services
        self.blockRepository = blockRepository

        let start = Self.calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date) ?? date
        self.startTime = start
        self.endTime = Self.calendar.date(
            byAdding: .minute,
            value: ScheduleMetrics.CreatePopup.defaultDurationMinutes,
            to: start
        ) ?? start
    }

    var canSubmit: Bool {
        endTime > startTime && !selectedServiceIds.isEmpty
    }

    func isSelected(_ service: Service) -> Bool {
        guard let id = service.id else { return false }
        return selectedServiceIds.contains(id)
    }

    func toggleSelection(of service: Service) {
        guard let id = service.id else { return }
        if selectedServiceIds.contains(id) {
            selectedServiceIds.remove(id)
        } else {
            selectedServiceIds.insert(id)
        }
    }

    func submit() async -> Bool {
        guard canSubmit else { return false }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let block = Block(
            id: nil,
            date: DateFormat.date.string(from: date),
            startTime: DateFormat.time.string(from: startTime),
            endTime: DateFormat.time.string(from: endTime),
            offeredServiceIds: Array(selectedServiceIds),
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        )

        do {
            try await blockRepository.addBlock(block)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = DateFormat.salonTimeZone
        return calendar
    }
}
