import SwiftUI

struct ConflictMark {
    let color: Color
    let softColor: Color
    let systemImage: String

    init(_ conflict: PlanConflict) {
        switch conflict {
        case .close:
            color = .warning
            softColor = .warningSoft
            systemImage = "exclamationmark.triangle.fill"
        case .overlap:
            color = .destructive
            softColor = .destructiveSoft
            systemImage = "exclamationmark.octagon.fill"
        }
    }
}
