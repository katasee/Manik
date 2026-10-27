struct ConflictEntry: Identifiable, Equatable {
    let id: String
    let text: String
}

enum ConflictNotice: Equatable {
    case overlap(ConflictEntry)
    case close([ConflictEntry])

    var blocksConfirm: Bool {
        switch self {
        case .overlap: true
        case .close: false
        }
    }

    var mark: ConflictMark {
        switch self {
        case .overlap: ConflictMark(.overlap)
        case .close: ConflictMark(.close)
        }
    }
}
