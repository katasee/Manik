import SwiftUI

extension View {
    func brandShadow(_ isActive: Bool = true) -> some View {
        shadow(color: isActive ? Color.shadow.opacity(0.22) : .clear, radius: 6, x: 0, y: 4)
    }

    func cardShadow() -> some View {
        shadow(color: Color.shadow.opacity(0.04), radius: 3, x: 0, y: 2)
            .shadow(color: Color.shadow.opacity(0.05), radius: 12, x: 0, y: 10)
    }

    func raisedShadow() -> some View {
        shadow(color: Color.shadow.opacity(0.05), radius: 2.5, x: 0, y: 2)
    }
}
