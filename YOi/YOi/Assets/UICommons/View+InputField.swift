import SwiftUI

private enum InputFieldLayout {
    static let font: CGFloat = 16
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 15
    static let cornerRadius: CGFloat = 16
}

extension View {
    func inputFieldStyle() -> some View {
        font(.elmsSans(.regular, InputFieldLayout.font))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, InputFieldLayout.horizontalPadding)
            .padding(.vertical, InputFieldLayout.verticalPadding)
            .raisedSurface(.rect(cornerRadius: InputFieldLayout.cornerRadius))
    }
}

#Preview {
    @Previewable @State var text = "olena@example.com"

    TextField("", text: $text)
        .inputFieldStyle()
        .padding()
        .background(Color.background)
}
