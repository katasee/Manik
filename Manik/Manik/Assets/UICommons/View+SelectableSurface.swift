import SwiftUI

extension View {
    func selectableSurface<S: InsettableShape>(isSelected: Bool, in shape: S) -> some View {
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
