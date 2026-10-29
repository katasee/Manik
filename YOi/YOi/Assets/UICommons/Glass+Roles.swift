import SwiftUI

@available(iOS 26, *)
extension Glass {
    static var primary: Glass {
        .regular.tint(Color.primaryFill)
    }

    static var destructive: Glass {
        .regular.tint(Color.destructiveFill)
    }
}
