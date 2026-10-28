import Foundation
import Observation

@MainActor
@Observable
final class StatsViewModel {
    private static let refreshInterval = 60

    private(set) var stats: MonthlyStats
    private(set) var monthTitle: String
    private(set) var hasLoaded = false

    private let slotRepository: SlotRepository

    private var slots: [Slot] = [] {
        didSet { rebuild() }
    }

    private var monthStart: Date {
        didSet {
            monthTitle = DateFormat.monthYear.string(from: monthStart)
            rebuild()
        }
    }

    init(slotRepository: SlotRepository = FirestoreSlotRepository()) {
        let start = StatsCalculator.monthStart(containing: .now)

        self.slotRepository = slotRepository
        self.monthStart = start
        self.monthTitle = DateFormat.monthYear.string(from: start)
        self.stats = MonthlyStats(
            totals: StatsCalculator.totals(
                slots: [],
                monthStart: start,
                now: .now
            )
        )
    }

    var canGoBack: Bool {
        monthStart > StatsCalculator.earliestMonthStart(now: .now)
    }

    var canGoForward: Bool {
        monthStart < StatsCalculator.monthStart(containing: .now)
    }

    func observeSlots() async {
        do {
            for try await updatedSlots in slotRepository.observeSlots() {
                slots = updatedSlots
                hasLoaded = true
            }
        } catch {
            hasLoaded = true
        }
    }

    func refreshStats() async {
        while Task.isCancelled == false {
            rebuild()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    func showPreviousMonth() {
        guard canGoBack else { return }
        guard let previous = DateFormat.salonCalendar.date(
            byAdding: .month,
            value: -1,
            to: monthStart
        ) else { return }

        monthStart = previous
    }

    func showNextMonth() {
        guard canGoForward else { return }
        guard let next = DateFormat.salonCalendar.date(
            byAdding: .month,
            value: 1,
            to: monthStart
        ) else { return }

        monthStart = next
    }

    private func rebuild() {
        stats = MonthlyStats(
            totals: StatsCalculator.totals(
                slots: slots,
                monthStart: monthStart,
                now: .now
            )
        )
    }
}
