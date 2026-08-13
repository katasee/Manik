import Foundation
import Observation

@MainActor
@Observable
final class BookingDatesViewModel {
    let offer: ServiceOffer

    private(set) var month: BookingMonth
    private(set) var daySlots: [BookingSlot] = []
    private(set) var selectedSlot: BookingSlot?

    private(set) var selectedDate: String? {
        didSet { daySlots = offer.slots.filter { $0.date == selectedDate } }
    }

    private let now: Date
    private let clientId: String
    private let blockRepository: BlockRepository

    init(
        offer: ServiceOffer,
        clientId: String,
        blockRepository: BlockRepository,
        now: Date = .now
    ) {
        self.offer = offer
        self.clientId = clientId
        self.blockRepository = blockRepository
        self.now = now
        self.month = BookingAvailability.month(
            startingAt: Self.anchor(for: offer, now: now),
            for: offer,
            now: now
        )

        let nearestDate = offer.nearestSlot?.date
        self.selectedDate = nearestDate
        self.daySlots = offer.slots.filter { $0.date == nearestDate }
    }

    var serviceName: String {
        offer.service.name
    }

    var priceLabel: String {
        ServiceFormat.price(offer.service.price)
    }

    var slotLabel: String? {
        guard let selectedSlot else { return nil }

        return "\(selectedSlot.shortDayLabel), \(selectedSlot.timeLabel)"
    }

    var confirmContext: BookingConfirmContext? {
        guard let selectedSlot else { return nil }

        return BookingConfirmContext(service: offer.service, slot: selectedSlot)
    }

    func makeConfirmViewModel(context: BookingConfirmContext) -> BookingConfirmViewModel {
        BookingConfirmViewModel(
            context: context,
            clientId: clientId,
            blockRepository: blockRepository
        )
    }

    func select(day: BookingDay) {
        guard day.isSelectable else { return }

        selectedDate = day.date
        selectedSlot = nil

        if day.isInMonth == false {
            rebuildMonth(startingAt: DateFormat.date.date(from: day.date))
        }
    }

    func select(slot: BookingSlot) {
        selectedSlot = slot
    }

    func goToPreviousMonth() {
        guard month.canGoBack else { return }

        shiftMonth(by: -1)
    }

    func goToNextMonth() {
        shiftMonth(by: 1)
    }

    private func shiftMonth(by value: Int) {
        rebuildMonth(
            startingAt: DateFormat.salonCalendar.date(
                byAdding: .month,
                value: value,
                to: month.start
            )
        )
    }

    private func rebuildMonth(startingAt start: Date?) {
        guard let start else { return }

        month = BookingAvailability.month(
            startingAt: start,
            for: offer,
            now: now
        )
    }

    private static func anchor(for offer: ServiceOffer, now: Date) -> Date {
        guard
            let nearest = offer.nearestSlot,
            let date = DateFormat.date.date(from: nearest.date)
        else { return now }

        return date
    }
}
