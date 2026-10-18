import Foundation

enum ServiceFormat {
    static let currencyCode = "PLN"

    static func price(_ value: Int) -> String {
        value.formatted(
            .currency(code: currencyCode)
            .precision(.fractionLength(0))
        )
    }

    static func summary(name: String?, price: Int?) -> String {
        if let name, let price {
            "\(name) · \(self.price(price))"
        } else {
            String(localized: "service.none")
        }
    }
}
