struct BookingDay: Identifiable {
    let date: String
    let numberLabel: String
    let isInMonth: Bool
    let isAvailable: Bool
    let isPast: Bool

    var id: String { date }

    var isSelectable: Bool {
        isAvailable && isPast == false
    }
}
