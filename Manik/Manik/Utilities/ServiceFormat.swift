import Foundation

enum ServiceFormat {
    static let currencyCode = "PLN"

    static func price(_ value: Int) -> String {
        value.formatted(
            .currency(code: currencyCode)
            .precision(.fractionLength(0))
        )
    }
}
