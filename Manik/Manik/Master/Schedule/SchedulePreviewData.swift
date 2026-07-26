#if DEBUG
enum SchedulePreviewData {
    static let services: [Service] = [
        Service(id: "svc-hybrid", name: "Манікюр гібридний (гель-лак)", durationMinutes: 90, price: 800),
        Service(id: "svc-classic", name: "Класичний манікюр", durationMinutes: 60, price: 500),
        Service(id: "svc-gel-correction", name: "Корекція гелем", durationMinutes: 90, price: 900),
        Service(id: "svc-french", name: "Френч", durationMinutes: 30, price: 200)
    ]
}
#endif
