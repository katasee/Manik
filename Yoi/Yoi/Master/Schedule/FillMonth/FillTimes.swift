struct FillTimes {
    private static let hourChips = WorkHours.fillHours.map { DateFormat.storageTime(minutesOfDay: $0 * 60) }

    private(set) var selected: Set<String> = []
    private var custom: Set<String> = []

    var all: [String] {
        (Self.hourChips + custom).sorted()
    }

    func isCustom(_ time: String) -> Bool {
        custom.contains(time)
    }

    mutating func toggle(_ time: String) {
        if selected.remove(time) == nil {
            selected.insert(time)
        }
    }

    mutating func addCustom(_ time: String) {
        if Self.hourChips.contains(time) == false {
            custom.insert(time)
        }

        selected.insert(time)
    }

    mutating func removeCustom(_ time: String) {
        guard custom.remove(time) != nil else { return }

        selected.remove(time)
    }
}
