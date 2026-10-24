import Foundation
import Observation

@MainActor
@Observable
final class MyPlansViewModel {
    private(set) var templates: [EventTemplate]

    init(templates: [EventTemplate] = []) {
        self.templates = templates.sortedByName()
    }

    func toggleActive(_ template: EventTemplate) {
        guard let index = templates.firstIndex(where: { $0.id == template.id }) else { return }

        templates[index].isActive.toggle()
    }

    func delete(_ template: EventTemplate) {
        templates.removeAll { $0.id == template.id }
    }
}
