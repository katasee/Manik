#if DEBUG
enum PlansPreviewData {
    static let templates: [EventTemplate] = [
        EventTemplate(id: "plan-boxing", emoji: "🥊", name: "Бокс", isActive: true),
        EventTemplate(id: "plan-gym", emoji: "🏋️", name: "Зал", isActive: true),
        EventTemplate(id: "plan-dentist", emoji: "🦷", name: "Стоматолог", isActive: true),
        EventTemplate(id: "plan-hairdresser", emoji: "💇‍♀️", name: "Перукар", isActive: false),
        EventTemplate(id: "plan-course", emoji: "🎓", name: "Курс з дизайну нігтів", isActive: true)
    ]
}
#endif
