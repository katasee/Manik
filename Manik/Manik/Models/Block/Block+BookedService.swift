import Foundation

extension Block {
    var bookedServiceLabel: String {
        bookedServiceName ?? String(localized: "common.service.unknown")
    }
}
