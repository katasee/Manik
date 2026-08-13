import Foundation
import Observation

@MainActor
@Observable
final class BookingConfirmViewModel {
    let context: BookingConfirmContext

    private(set) var isSaving = false
    private(set) var isBooked = false
    private(set) var failure: BookingFailure?

    private let clientId: String
    private let blockRepository: BlockRepository

    init(
        context: BookingConfirmContext,
        clientId: String,
        blockRepository: BlockRepository
    ) {
        self.context = context
        self.clientId = clientId
        self.blockRepository = blockRepository
    }

    var serviceName: String {
        context.service.name
    }

    var slotLabel: String {
        "\(context.slot.dayLabel), \(context.slot.timeLabel)"
    }

    var priceLabel: String {
        ServiceFormat.price(context.service.price)
    }

    func book() async {
        guard isSaving == false, isBooked == false else { return }
        guard let serviceId = context.service.id else {
            failure = .generic
            return
        }
        guard isUpcoming else {
            failure = .expired
            return
        }

        isSaving = true
        failure = nil
        defer { isSaving = false }

        do {
            try await blockRepository.book(
                blockId: context.slot.id,
                clientId: clientId,
                bookedServiceId: serviceId
            )
            isBooked = true
        } catch BookingError.slotUnavailable {
            failure = .slotTaken
        } catch {
            failure = .generic
        }
    }

    private var isUpcoming: Bool {
        guard let startsAt = context.slot.startsAt else { return false }

        return startsAt > .now
    }
}
