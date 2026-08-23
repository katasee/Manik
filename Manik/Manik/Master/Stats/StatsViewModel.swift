import Foundation
import Observation

@MainActor
@Observable
final class StatsViewModel {
    private static let refreshInterval = 60

    private(set) var stats: MonthlyStats
    private(set) var monthTitle: String
    private(set) var hasLoaded = false

    private let blockRepository: BlockRepository

    private var blocks: [Block] = [] {
        didSet { rebuild() }
    }

    private var monthStart: Date {
        didSet {
            monthTitle = DateFormat.monthYear.string(from: monthStart)
            rebuild()
        }
    }

    init(blockRepository: BlockRepository = FirestoreBlockRepository()) {
        let start = StatsCalculator.monthStart(containing: .now)

        self.blockRepository = blockRepository
        self.monthStart = start
        self.monthTitle = DateFormat.monthYear.string(from: start)
        self.stats = MonthlyStats(
            totals: StatsCalculator.totals(
                blocks: [],
                monthStart: start,
                now: .now
            )
        )
    }

    var canGoForward: Bool {
        monthStart < StatsCalculator.monthStart(containing: .now)
    }

    func observeBlocks() async {
        for await updatedBlocks in blockRepository.observeBlocks() {
            blocks = updatedBlocks

            guard hasLoaded == false else { continue }

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
                blocks: blocks,
                monthStart: monthStart,
                now: .now
            )
        )
    }
}
