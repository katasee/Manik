import Foundation
import Observation

@MainActor
@Observable
final class ClientFormViewModel: Identifiable {
    var fields = ClientFormFields()

    private(set) var isSaving = false
    private var hasSubmitted = false
    private var hasSaveFailed = false

    private let takenHandles: Set<String>
    private let clientRepository: ClientRepository

    init(takenHandles: Set<String>, clientRepository: ClientRepository) {
        self.takenHandles = takenHandles
        self.clientRepository = clientRepository
    }

    var errors: ClientFormErrors {
        ClientFormErrors(
            instagram: instagramError,
            phone: hasSubmitted ? phoneError : nil,
            save: hasSaveFailed ? .saveFailed : nil
        )
    }

    func applyMasks() {
        let instagram = Client.normalizedInstagram(fields.instagram)
        let phone = PhoneFormat.grouped(PhoneFormat.national(from: fields.phone))

        if fields.instagram != instagram {
            fields.instagram = instagram
        }

        if fields.phone != phone {
            fields.phone = phone
        }
    }

    func submit() async -> Bool {
        guard isSaving == false else { return false }

        hasSubmitted = true
        hasSaveFailed = false

        guard let client = makeClient() else { return false }

        isSaving = true
        defer { isSaving = false }

        do {
            try await clientRepository.add(client)
            return true
        } catch {
            hasSaveFailed = true
            return false
        }
    }

    private var handle: String? {
        Self.nonEmpty(Client.normalizedInstagram(fields.instagram))
    }

    private var name: String? {
        Self.nonEmpty(fields.name.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var nationalPhone: String {
        PhoneFormat.national(from: fields.phone)
    }

    private var instagramError: ClientFormError? {
        if let handle, takenHandles.contains(handle) {
            .duplicateHandle
        } else if hasSubmitted, handle == nil, name == nil {
            .missingNameOrHandle
        } else {
            nil
        }
    }

    private var phoneError: ClientFormError? {
        nationalPhone.isEmpty || PhoneFormat.isComplete(nationalPhone) ? nil : .incompletePhone
    }

    private func makeClient() -> Client? {
        guard instagramError == nil, phoneError == nil else { return nil }

        return Client(
            id: nil,
            name: name,
            instagram: handle,
            phone: PhoneFormat.stored(national: nationalPhone),
            createdAt: .now
        )
    }

    private static func nonEmpty(_ text: String) -> String? {
        text.isEmpty ? nil : text
    }
}
