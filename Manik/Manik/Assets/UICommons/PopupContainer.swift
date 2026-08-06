import SwiftUI

private enum PopupContainerLayout {
    static let cornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 20
    static let rowSpacing: CGFloat = 16
    static let horizontalInset: CGFloat = 16
    static let backdropOpacity: Double = 0.5
    static let fade = Animation.easeOut(duration: 0.2)
}

struct PopupContainer<Content: View>: View {
    let dismissLabel: LocalizedStringKey
    let onDismiss: () -> Void
    @ViewBuilder let content: (_ dismiss: @escaping () -> Void) -> Content

    @State private var isVisible = false

    var body: some View {
        ZStack {
            backdrop
            card
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(PopupContainerLayout.fade) {
                isVisible = true
            }
        }
    }

    private var backdrop: some View {
        Button(action: fadeOutAndDismiss) {
            Rectangle()
                .opacity(PopupContainerLayout.backdropOpacity)
        }
        .buttonStyle(.plain)
        .ignoresSafeArea()
        .accessibilityLabel(Text(dismissLabel))
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            content(fadeOutAndDismiss)
        }
        .padding(PopupContainerLayout.cardPadding)
        .background(
            Color.background,
            in: .rect(cornerRadius: PopupContainerLayout.cornerRadius)
        )
        .compositingGroup()
        .brandShadow()
        .padding(.horizontal, PopupContainerLayout.horizontalInset)
    }

    private func fadeOutAndDismiss() {
        withAnimation(PopupContainerLayout.fade) {
            isVisible = false
        } completion: {
            onDismiss()
        }
    }
}
