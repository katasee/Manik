import Foundation
import Observation

@MainActor
@Observable
final class AddPlanViewModel {
    var days: MonthDaySelection
    var times = PlanTimes()

    private var templateChoice: TemplateChoice

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
        templateChoice = TemplateChoice(templates: templates)
    }

    var templateChips: [ChoiceChip] {
        templateChoice.chips
    }

    var hasTemplates: Bool {
        templateChoice.isEmpty == false
    }

    var selectedTemplateId: String? {
        templateChoice.selectedId
    }

    var canAdd: Bool {
        days.selected.isEmpty == false
            && templateChoice.selectedTemplate != nil
            && times.isValid
    }

    func selectTemplate(_ id: String) {
        templateChoice.select(id)
    }

    func makePlans() -> [PlanEvent] {
        guard canAdd, let template = templateChoice.selectedTemplate, let templateId = template.id else { return [] }

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
}
