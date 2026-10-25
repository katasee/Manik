import Foundation

struct TemplateChoice {
    private(set) var selectedId: String?

    private let offered: [EventTemplate]

    init(templates: [EventTemplate]) {
        offered = templates.filter(\.isActive).sortedByName()
    }

    var chips: [ChoiceChip] {
        offered.compactMap { template in
            template.id.map { id in
                ChoiceChip(
                    id: id,
                    title: "\(template.emoji) \(template.name)",
                    isSelected: id == selectedId
                )
            }
        }
    }

    var selectedTemplate: EventTemplate? {
        offered.first { $0.id == selectedId }
    }

    var isEmpty: Bool {
        chips.isEmpty
    }

    mutating func select(_ id: String) {
        selectedId = id
    }
}
