extension Block {
    var startMinutes: Int { Block.minutes(from: startTime) }
    var endMinutes: Int { Block.minutes(from: endTime) }

    private static func minutes(from time: String) -> Int {
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1])
        else { return 0 }

        return hour * 60 + minute
    }
}
