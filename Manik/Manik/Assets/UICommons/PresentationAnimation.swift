import SwiftUI

func withoutPresentationAnimation(_ changes: () -> Void) {
    var transaction = Transaction()
    transaction.disablesAnimations = true

    withTransaction(transaction, changes)
}
