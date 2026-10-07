enum WorkHours {
    static let working = 8..<22
    static let freeSlotToleranceMinutes = 20
    static let defaultSlotDurationMinutes = 60
    static let slotStepMinutes = 15

    static var openingMinutes: Int { working.lowerBound * 60 }
    static var closingMinutes: Int { working.upperBound * 60 }
}
