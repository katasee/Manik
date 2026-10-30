import SwiftUI

extension View {
    @ViewBuilder
    func glassEffectGroup() -> some View {
        if #available(iOS 26, *) {
            GlassEffectContainer {
                self
            }
        } else {
            self
        }
    }
}
