import Foundation

protocol Named {
    var name: String { get }
}

extension Sequence where Element: Named {
    func sortedByName() -> [Element] {
        sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
