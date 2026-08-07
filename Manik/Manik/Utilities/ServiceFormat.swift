import Foundation

enum ServiceFormat {
    static let currencyCode = "PLN"

    static func price(_ value: Double) -> String {
        value.formatted(
            .currency(code: currencyCode)
            .precision(.fractionLength(0...2))
        )
    }

    static func duration(minutes: Int) -> String {
        Duration.seconds(minutes * 60)
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }
}
