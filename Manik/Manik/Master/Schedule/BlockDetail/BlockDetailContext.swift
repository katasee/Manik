import Foundation

struct BlockDetailContext: Identifiable {
    let id = UUID()
    let block: Block
    let bookedServiceName: String
    let offeredServiceNames: String
}

extension BlockDetailContext {
    init(_ scheduled: ScheduledBlock) {
        self.init(
            block: scheduled.block,
            bookedServiceName: scheduled.bookedServiceName,
            offeredServiceNames: scheduled.serviceNames
        )
    }
}
