import SwiftUI

struct RoundIconLabel: View {
    let systemImage: String
    var size: RoundIconButton.Size = .regular

    var body: some View {
        if #available(iOS 26, *) {
            glyph
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            glyph
                .raisedSurface(.circle)
        }
    }

    private var glyph: some View {
        Image(systemName: systemImage)
            .font(.elmsSans(.medium, size.glyph))
            .foregroundStyle(Color.accentColor)
            .frame(width: size.diameter, height: size.diameter)
    }
}

#Preview {
    HStack(spacing: 16) {
        RoundIconLabel(systemImage: "bubble.left")
        RoundIconLabel(systemImage: "pencil", size: .small)
    }
    .padding()
    .background(Color.background)
}
