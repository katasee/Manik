import Foundation
import Observation

@MainActor
@Observable
final class CancelBookingViewModel {
    let context: CancelBookingContext

    private(set) var isCancelling = false
    private(set) var hasFailed = false

    private let blockRepository: BlockRepository

    init(
        context: CancelBookingContext,
        blockRepository: BlockRepository
    ) {
        self.context = context
        self.blockRepository = blockRepository
    }

    var serviceName: String {
        context.serviceName
    }

    var slotLabel: String {
        "\(context.dayLabel), \(context.timeRangeLabel)"
    }

    func cancel() async -> Bool {
        guard isCancelling == false else { return false }

        isCancelling = true
        hasFailed = false
        defer { isCancelling = false }

        do {
            try await blockRepository.cancel(blockId: context.id)

            return true
        } catch {
            hasFailed = true

            return false
        }
    }
}
