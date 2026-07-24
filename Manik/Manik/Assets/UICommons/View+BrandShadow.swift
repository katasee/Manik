import SwiftUI

extension View {
    func brandShadow(_ isActive: Bool = true) -> some View {
        shadow(color: isActive ? Color.ink.opacity(0.4) : .clear, radius: 8, x: 0, y: 6)
    }
}
