import Foundation
import Observation

@MainActor
@Observable
final class MyBookingsViewModel {
    private static let refreshInterval = 60

    private(set) var sections: [MyBookingSection] = []
    private(set) var hasLoaded = false

    private let clientId: String
    private let blockRepository: BlockRepository

    private var blocks: [Block] = [] {
        didSet { rebuild() }
    }

    init(
        clientId: String,
        blockRepository: BlockRepository = FirestoreBlockRepository()
    ) {
        self.clientId = clientId
        self.blockRepository = blockRepository
    }

    func makeCancelViewModel(context: CancelBookingContext) -> CancelBookingViewModel {
        CancelBookingViewModel(
            context: context,
            blockRepository: blockRepository
        )
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks
            hasLoaded = true
        }
    }

    func refreshSections() async {
        while Task.isCancelled == false {
            rebuild()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    private func rebuild() {
        sections = MyBookingsList.sections(
            blocks: blocks,
            clientId: clientId,
            now: .now
        )
    }
}
