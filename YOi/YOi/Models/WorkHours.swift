enum WorkHours {
    static let fillHours = 8...19
    static let customHours = 7...22
    static let minuteStep = 15
    static let defaultCustomTime = ClockTime(minutesOfDay: 9 * 60 + 30)
    static let defaultPlanStart = ClockTime(minutesOfDay: 10 * 60)
    static let defaultPlanMinutes = 60
    static let planLeadMinutes = 60
    static let latestTime = ClockTime(minutesOfDay: (customHours.upperBound + 1) * 60 - minuteStep)
}
