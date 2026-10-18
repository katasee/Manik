import Foundation

extension Sequence where Element == Service {
    func sortedByName() -> [Service] {
        sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
