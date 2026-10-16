import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    var selectedDate = Date.now

    private(set) var hasLoaded = false
    private(set) var hasFailed = false
    private var slots: [Slot] = []

    private let slotRepository: SlotRepository

    init(slotRepository: SlotRepository = FirestoreSlotRepository()) {
        self.slotRepository = slotRepository
    }

    func items(now: Date) -> [SlotItem] {
        let day = DateFormat.date.string(from: selectedDate)

        return slots
            .filter { $0.date == day }
            .sorted(by: Slot.chronologically)
            .map { SlotItem(slot: $0, now: now) }
    }

    func observeSlots() async {
        hasFailed = false

        do {
            for try await updatedSlots in slotRepository.observeSlots() {
                slots = updatedSlots
                hasLoaded = true
            }
        } catch {
            slots = []
            hasFailed = true
            hasLoaded = true
        }
    }

    func delete(id: String) {
        try? slotRepository.delete(id: id)
    }

    func makeFillMonthViewModel(now: Date = .now) -> FillMonthViewModel {
        FillMonthViewModel(
            month: selectedDate,
            existing: slots,
            now: now,
            slotRepository: slotRepository
        )
    }
}
