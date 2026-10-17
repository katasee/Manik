import Foundation

struct MonthPager {
    private(set) var grid: MonthGrid
    let earliest: MonthGrid

    init(showing date: Date, earliest earliestDate: Date) {
        let earliest = MonthGrid(containing: earliestDate)
        let requested = MonthGrid(containing: date)

        grid = requested.start < earliest.start ? earliest : requested
        self.earliest = earliest
    }

    var canGoBack: Bool {
        grid != earliest
    }

    @discardableResult
    mutating func showPrevious() -> Bool {
        guard canGoBack else { return false }

        grid = grid.shifted(by: -1)

        return true
    }

    mutating func showNext() {
        grid = grid.shifted(by: 1)
    }
}
