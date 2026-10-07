struct ClockTime: Equatable {
    var hour: Int {
        didSet {
            if hour == WorkHours.working.upperBound { minute = 0 }
        }
    }
    var minute: Int

    init(minutesOfDay: Int) {
        hour = minutesOfDay / 60
        minute = minutesOfDay % 60
    }

    var minutesOfDay: Int { hour * 60 + minute }
}
