import Foundation
import Observation

@MainActor
@Observable
final class CreateBlockViewModel {
    var date: Date
    var startTime: Date
    var endTime: Date

    var startTimeText: String {
        didSet {
            guard let parsed = Self.parseTime(startTimeText, into: startTime) else { return }
            startTime = parsed
        }
    }

    var endTimeText: String {
        didSet {
            guard let parsed = Self.parseTime(endTimeText, into: endTime) else { return }
            endTime = parsed
        }
    }

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

        let calendar = Self.calendar
        let start = calendar.date(
            bySettingHour: startHour,
            minute: 0,
            second: 0,
            of: date
        ) ?? date
        self.startTime = start
        let end = calendar.date(
            byAdding: .minute,
            value: ScheduleMetrics.CreatePopup.defaultDurationMinutes,
            to: start
        ) ?? start
        self.endTime = end

        self.startTimeText = DateFormat.time.string(from: start)
        self.endTimeText = DateFormat.time.string(from: end)
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

    private static func parseTime(_ text: String, into date: Date) -> Date? {
        let parts = text.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]), (0...23).contains(hour),
              let minute = Int(parts[1]), (0...59).contains(minute)
        else { return nil }

        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        )
    }
}
