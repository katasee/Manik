import Foundation
import Observation

@MainActor
@Observable
final class AddServiceViewModel {
    var name = ""
    var priceText = ""
    
    private(set) var errorMessage: String?
    private(set) var isSaving = false
    
    private let serviceRepository: ServiceRepository
    
    init(serviceRepository: ServiceRepository) {
        self.serviceRepository = serviceRepository
    }
    
    var canSubmit: Bool {
        trimmedName.isEmpty == false && (Self.parsePrice(priceText) ?? 0) > 0
    }
    
    func submit() async -> Bool {
        guard canSubmit, let price = Self.parsePrice(priceText) else { return false }
        
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        
        do {
            try await serviceRepository.add(
                Service(
                    id: nil,
                    name: trimmedName,
                    price: price
                )
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func parsePrice(_ text: String) -> Double? {
        try? Double(text, format: .number.locale(.current))
    }
}
