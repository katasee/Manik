enum WorkHours {
    static let fillHours = 8...19
    static let customHours = 7...22
    static let minuteStep = 15
    static let defaultCustomTime = ClockTime(minutesOfDay: 9 * 60 + 30)
}
