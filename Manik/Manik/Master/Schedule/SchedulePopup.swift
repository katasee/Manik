import Foundation

enum SchedulePopup: Identifiable {
    case createSlot(CreateBlockContext)
    case blockDetail(BlockDetailContext)

    var id: UUID {
        switch self {
        case .createSlot(let context): context.id
        case .blockDetail(let context): context.id
        }
    }
}
