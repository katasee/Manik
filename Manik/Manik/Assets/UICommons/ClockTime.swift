struct ClockTime: Equatable {
    var hour: Int
    var minute: Int

    init(minutesOfDay: Int) {
        hour = minutesOfDay / 60
        minute = minutesOfDay % 60
    }

    var minutesOfDay: Int { hour * 60 + minute }
}
