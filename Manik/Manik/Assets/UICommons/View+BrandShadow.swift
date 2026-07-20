import SwiftUI

extension View {
    func brandShadow(_ isActive: Bool = true) -> some View {
        shadow(color: isActive ? Color.textPrimary.opacity(0.4) : .clear, radius: 8, x: 0, y: 6)
    }
}
