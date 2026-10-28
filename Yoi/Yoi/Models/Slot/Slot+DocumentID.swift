import Foundation

extension Slot {
    static func documentId(date: String, time: String) -> String {
        "\(date)_\(time.replacing(":", with: ""))"
    }
}
