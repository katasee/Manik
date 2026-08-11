#if DEBUG
enum ServicesPreviewData {
    static let services: [Service] = [
        Service(
            id: "svc-hybrid",
            name: "Манікюр гібридний (гель-лак)",
            price: 800,
            isActive: true
        ),
        Service(
            id: "svc-classic",
            name: "Класичний манікюр",
            price: 500,
            isActive: true
        ),
        Service(
            id: "svc-gel-correction",
            name: "Корекція гелем",
            price: 900,
            isActive: false
        ),
        Service(id: "svc-french", name: "Френч", price: 200)
    ]
}
#endif
