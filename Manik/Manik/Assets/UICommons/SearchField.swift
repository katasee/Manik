import SwiftUI

struct SearchField: View {
    @Binding var text: String
    let placeholderKey: LocalizedStringKey

    private enum Layout {
        static let spacing: CGFloat = 10
        static let glyph: CGFloat = 16
        static let tapTarget: CGFloat = 44
        static let tapVerticalOverflow: CGFloat = 12
        static let tapTrailingOverflow: CGFloat = 14
    }

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Image(systemName: "magnifyingglass")
                .font(.elmsSans(.medium, Layout.glyph))
                .foregroundStyle(Color.textSecondary)
                .accessibilityHidden(true)

            TextField(placeholderKey, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if text.isEmpty == false {
                clearButton
            }
        }
        .inputFieldStyle()
    }

    private var clearButton: some View {
        Button(action: clear) {
            Image(systemName: "xmark.circle.fill")
                .font(.elmsSans(.regular, Layout.glyph))
                .foregroundStyle(Color.textSecondary)
                .frame(width: Layout.tapTarget, height: Layout.tapTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(.vertical, -Layout.tapVerticalOverflow)
        .padding(.trailing, -Layout.tapTrailingOverflow)
        .accessibilityLabel(Text("common.action.clear"))
    }

    private func clear() {
        text = ""
    }
}

#Preview {
    @Previewable @State var empty = ""
    @Previewable @State var typed = "olya"

    VStack(spacing: 16) {
        SearchField(text: $empty, placeholderKey: "clients.search.placeholder")
        SearchField(text: $typed, placeholderKey: "clients.search.placeholder")
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
