import SwiftUI

extension View {
    @ViewBuilder
    func selectableSurface<S: InsettableShape>(isSelected: Bool, in shape: S) -> some View {
        if #available(iOS 26, *) {
            glassEffect(
                isSelected ? .primary.interactive() : .regular.interactive(),
                in: shape
            )
        } else {
            background {
                if isSelected {
                    shape
                        .fill(Color.primaryFill)
                        .brandShadow()
                } else {
                    Color.clear
                        .raisedSurface(shape)
                }
            }
        }
    }
}
