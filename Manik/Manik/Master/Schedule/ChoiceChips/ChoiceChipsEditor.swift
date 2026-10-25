import SwiftUI

struct ChoiceChipsEditor: View {
    let titleKey: LocalizedStringKey
    let chips: [ChoiceChip]
    let canSave: Bool
    let onToggle: (String) -> Void
    let onBack: () -> Void
    let onSave: () -> Void

    @State private var chipsHeight: CGFloat?

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SectionLabel(titleKey: titleKey)

            ScrollView {
                ChoiceChips(chips: chips, onToggle: onToggle)
                    .padding(ScheduleMetrics.Spacing.scrollShadowInset)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        chipsHeight = height
                    }
            }
            .frame(maxHeight: chipsHeight)
            .opacity(chipsHeight == nil ? 0 : 1)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(-ScheduleMetrics.Spacing.scrollShadowInset)

            HStack {
                PopupDismissButton(titleKey: "common.action.back", action: onBack)

                Spacer()

                CapsuleButton(
                    titleKey: "schedule.actions.save",
                    role: .primary,
                    isEnabled: canSave,
                    action: onSave
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    ChoiceChipsEditor(
        titleKey: "schedule.book.service",
        chips: SchedulePreviewData.serviceChips,
        canSave: true,
        onToggle: { _ in },
        onBack: {},
        onSave: {}
    )
    .padding()
    .background(Color.card)
}
#endif
