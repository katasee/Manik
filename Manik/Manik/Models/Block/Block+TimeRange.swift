import Foundation

extension Block {
    var timeRangeLabel: String {
        "\(DateFormat.displayTime(startTime)) – \(DateFormat.displayTime(endTime))"
    }
}
