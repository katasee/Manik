import SwiftUI

struct ListStatusOverlay: View {
    let hasLoaded: Bool
    let isEmpty: Bool
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey

    private enum Layout {
        static let title: CGFloat = 18
        static let message: CGFloat = 14
    }

    var body: some View {
        if hasLoaded == false {
            ProgressView()
                .tint(Color.ink)
        } else if isEmpty {
            ContentUnavailableView {
                Text(titleKey)
                    .font(.elmsSans(.bold, Layout.title))
                    .foregroundStyle(Color.ink)
            } description: {
                Text(messageKey)
                    .font(.elmsSans(.regular, Layout.message))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

#Preview("Завантаження") {
    Color.background
        .overlay {
            ListStatusOverlay(
                hasLoaded: false,
                isEmpty: true,
                titleKey: "services.empty.title",
                messageKey: "services.empty.message"
            )
        }
}

#Preview("Порожньо") {
    Color.background
        .overlay {
            ListStatusOverlay(
                hasLoaded: true,
                isEmpty: true,
                titleKey: "services.empty.title",
                messageKey: "services.empty.message"
            )
        }
}
