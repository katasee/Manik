struct ScheduledBlock: Identifiable {
    let block: Block
    let depth: Int
    let serviceNames: String
    let bookedServiceName: String

    var id: String {
        block.id ?? "\(block.date)-\(block.startTime)-\(block.endTime)"
    }
}
