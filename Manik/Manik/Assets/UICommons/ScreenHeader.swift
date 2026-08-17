import SwiftUI

struct ScreenHeader: View {
    let titleKey: LocalizedStringKey
    var onBack: (() -> Void)?

    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let title: CGFloat = 22
        static let backIcon: CGFloat = 26
        static let backTapTarget: CGFloat = 44
    }

    var body: some View {
        ZStack {
            Text(titleKey)
                .font(.elmsSans(.bold, Layout.title))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .padding(.horizontal, Layout.backTapTarget)

            if let onBack {
                HStack {
                    Button("common.action.back", systemImage: "chevron.left", action: onBack)
                        .labelStyle(.iconOnly)
                        .font(.elmsSans(.regular, Layout.backIcon))
                        .foregroundStyle(Color.ink)
                        .frame(
                            minWidth: Layout.backTapTarget,
                            minHeight: Layout.backTapTarget,
                            alignment: .leading
                        )
                        .contentShape(.rect)

                    Spacer()
                }
            }
        }
        .frame(minHeight: Layout.backTapTarget)
        .padding(.horizontal, Layout.horizontalPadding)
    }
}

#Preview {
    VStack(spacing: 24) {
        ScreenHeader(titleKey: "services.title", onBack: {})
        ScreenHeader(titleKey: "tabBar.tab.myBookings")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
