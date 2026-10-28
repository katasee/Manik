import SwiftUI

struct PlanEmojiGrid: View {
    @Binding var selection: String

    @State private var position = ScrollPosition(idType: String.self)

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: PlansMetrics.Spacing.gridSpacing),
        count: PlansMetrics.Grid.columns
    )

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: PlansMetrics.Spacing.gridSpacing) {
                ForEach(EventTemplate.emojiChoices, id: \.self) { emoji in
                    Button { select(emoji) } label: {
                        cell(emoji)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(emoji == selection ? .isSelected : [])
                }
            }
            .scrollTargetLayout()
            .padding(PlansMetrics.Spacing.gridShadowInset)
        }
        .frame(height: PlansMetrics.Size.gridVisibleHeight)
        .scrollIndicators(.hidden)
        .scrollPosition($position, anchor: .center)
        .onAppear {
            position.scrollTo(id: selection, anchor: .center)
        }
    }

    private func select(_ emoji: String) {
        selection = emoji
    }

    private func cell(_ emoji: String) -> some View {
        let shape = RoundedRectangle(cornerRadius: PlansMetrics.Size.gridCellCornerRadius)

        return Text(verbatim: emoji)
            .font(.elmsSans(.regular, PlansMetrics.Size.gridGlyph))
            .frame(maxWidth: .infinity, minHeight: PlansMetrics.Size.gridCell)
            .contentShape(shape)
            .selectableSurface(isSelected: emoji == selection, in: shape)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection = "🎉"

    PlanEmojiGrid(selection: $selection)
        .padding()
        .background(Color.card)
}
#endif
