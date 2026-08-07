import Foundation

#if DEBUG
enum SchedulePreviewData {
    static let services: [Service] = [
        Service(id: "svc-hybrid", name: "Манікюр гібридний (гель-лак)", durationMinutes: 90, price: 800),
        Service(id: "svc-classic", name: "Класичний манікюр", durationMinutes: 60, price: 500),
        Service(id: "svc-gel-correction", name: "Корекція гелем", durationMinutes: 90, price: 900),
        Service(id: "svc-french", name: "Френч", durationMinutes: 30, price: 200)
    ]

    static let blocks: [Block] = [
        Block(
            id: "preview-morning",
            date: today,
            startTime: "09:00",
            endTime: "10:30",
            offeredServiceIds: ["svc-hybrid", "svc-french"],
            bookedServiceId: nil,
            status: .available,
            clientId: nil
        ),
        Block(
            id: "preview-overlapping",
            date: today,
            startTime: "10:00",
            endTime: "11:00",
            offeredServiceIds: ["svc-gel-correction"],
            bookedServiceId: "svc-gel-correction",
            status: .pending,
            clientId: "client-olena"
        ),
        Block(
            id: "preview-afternoon",
            date: today,
            startTime: "15:00",
            endTime: "16:00",
            offeredServiceIds: ["svc-classic"],
            bookedServiceId: "svc-classic",
            status: .confirmed,
            clientId: "client-olena"
        )
    ]

    static let scheduledBlocks: [ScheduledBlock] = [
        scheduled(blocks[0]),
        scheduled(blocks[1], depth: 1),
        scheduled(blocks[2])
    ]

    static func scheduled(_ block: Block, depth: Int = 0) -> ScheduledBlock {
        ScheduledBlock(
            block: block,
            depth: depth,
            serviceNames: offeredServiceNames(for: block),
            bookedServiceName: bookedServiceName(for: block)
        )
    }

    static func detailContext(for block: Block) -> BlockDetailContext {
        BlockDetailContext(scheduled(block))
    }

    static func bookedServiceName(for block: Block) -> String {
        guard let bookedServiceId = block.bookedServiceId else { return "" }

        return services.first { $0.id == bookedServiceId }?.name ?? ""
    }

    static let freeHours = Set(WorkHours.working).subtracting([9, 10, 11, 15])

    static func offeredServiceNames(for block: Block) -> String {
        block.offeredServiceIds
            .compactMap { serviceId in services.first { $0.id == serviceId }?.name }
            .joined(separator: ", ")
    }

    private static let today = DateFormat.date.string(from: .now)
}
#endif
