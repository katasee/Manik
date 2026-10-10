import SwiftUI

struct SearchField: View {
    let placeholderKey: LocalizedStringKey
    @Binding var text: String

    private enum Layout {
        static let spacing: CGFloat = 10
        static let glyph: CGFloat = 16
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
        }
        .buttonStyle(.plain)
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
        SearchField(placeholderKey: "clients.search.placeholder", text: $empty)
        SearchField(placeholderKey: "clients.search.placeholder", text: $typed)
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
