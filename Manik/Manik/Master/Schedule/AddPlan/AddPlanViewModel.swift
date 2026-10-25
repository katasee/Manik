import Foundation
import Observation

@MainActor
@Observable
final class AddPlanViewModel {
    var days: MonthDaySelection
    var times = PlanTimes()

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

    var canAdd: Bool {
        days.selected.isEmpty == false
            && selectedTemplate != nil
            && times.isValid
    }

    func selectTemplate(_ id: String) {
        selectedTemplateId = id
    }

    func makePlans() -> [PlanEvent] {
        guard canAdd, let template = selectedTemplate, let templateId = template.id else { return [] }

        return days.selected.sorted().map { date in
            PlanEvent(
                date: date,
                startTime: times.startTime,
                endTime: times.endTime,
                templateId: templateId,
                emoji: template.emoji,
                name: template.name
            )
        }
    }

    private var selectedTemplate: EventTemplate? {
        templates.first { $0.id == selectedTemplateId }
    }
}
