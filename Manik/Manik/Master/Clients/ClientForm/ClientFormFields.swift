struct ClientFormFields: Equatable {
    var instagram = ""
    var name = ""
    var phone = ""
}

extension ClientFormFields {
    init(client: Client) {
        instagram = client.instagram ?? ""
        name = client.name ?? ""
        phone = PhoneFormat.grouped(PhoneFormat.national(from: client.phone ?? ""))
    }
}
