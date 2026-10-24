import Foundation
import Observation

enum PlanTimeField {
    case start
    case end
}

@MainActor
@Observable
final class AddPlanViewModel {
    var days: MonthDaySelection
    var start = WorkHours.defaultPlanStart
    var end = AddPlanViewModel.endTime(after: WorkHours.defaultPlanStart)
    var editing = PlanTimeField.start

    private(set) var selectedTemplateId: String?

    private let templates: [EventTemplate]

    init(
        month: Date,
        templates: [EventTemplate],
        plannedDays: Set<String>,
        now: Date
    ) {
        days = MonthDaySelection(
            month: month,
            now: now,
            markedDays: plannedDays
        )
        self.templates = templates.filter(\.isActive).sortedByName()
    }

    var templateChips: [ChoiceChip] {
        templates.compactMap { template in
            template.id.map { id in
                ChoiceChip(
                    id: id,
                    title: "\(template.emoji) \(template.name)",
                    isSelected: id == selectedTemplateId
                )
            }
        }
    }

    var hasTemplates: Bool {
        templates.isEmpty == false
    }

    var startText: String {
        DateFormat.displayTime(storageTime(start))
    }

    var endText: String {
        DateFormat.displayTime(storageTime(end))
    }

    var canAdd: Bool {
        days.selected.isEmpty == false
            && selectedTemplate != nil
            && end.minutesOfDay > start.minutesOfDay
    }

    func selectTemplate(_ id: String) {
        selectedTemplateId = id
    }

    func keepEndAfterStart() {
        guard end.minutesOfDay <= start.minutesOfDay else { return }

        end = Self.endTime(after: start)
    }

    func makePlans() -> [PlanEvent] {
        guard canAdd, let template = selectedTemplate, let templateId = template.id else { return [] }

        return days.selected.sorted().map { date in
            PlanEvent(
                date: date,
                startTime: storageTime(start),
                endTime: storageTime(end),
                templateId: templateId,
                emoji: template.emoji,
                name: template.name
            )
        }
    }

    private static func endTime(after start: ClockTime) -> ClockTime {
        ClockTime(
            minutesOfDay: min(
                start.minutesOfDay + WorkHours.defaultPlanMinutes,
                WorkHours.latestTime.minutesOfDay
            )
        )
    }

    private var selectedTemplate: EventTemplate? {
        templates.first { $0.id == selectedTemplateId }
    }

    private func storageTime(_ time: ClockTime) -> String {
        DateFormat.storageTime(minutesOfDay: time.minutesOfDay)
    }
}
