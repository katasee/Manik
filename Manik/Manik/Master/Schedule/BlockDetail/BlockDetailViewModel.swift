import Foundation
import Observation

@MainActor
@Observable
final class BlockDetailViewModel {
    private(set) var runningAction: BlockAction?
    var errorMessage: String?

    private let block: Block
    private let blockRepository: BlockRepository

    init(block: Block, blockRepository: BlockRepository = FirestoreBlockRepository()) {
        self.block = block
        self.blockRepository = blockRepository
    }

    var isBusy: Bool {
        runningAction != nil
    }

    var availableActions: [BlockAction] {
        switch block.status {
        case .available: []
        case .pending: [.decline, .confirm]
        case .confirmed: [.cancelBooking]
        }
    }

    func perform(_ action: BlockAction) async -> Bool {
        guard let blockId = block.id else { return false }

        runningAction = action
        errorMessage = nil
        defer { runningAction = nil }

        do {
            switch action {
            case .confirm: try await blockRepository.confirm(blockId: blockId)
            case .decline: try await blockRepository.decline(blockId: blockId)
            case .cancelBooking: try await blockRepository.cancel(blockId: blockId)
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
