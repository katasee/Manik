import SwiftUI

struct SendScheduleTextStep: View {
    let monthTitle: String
    let canGoBack: Bool
    let text: String?
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onCopy: () -> Void
    let onSend: () -> Void

    @State private var copyCount = 0
    @State private var textHeight: CGFloat?

    private var isCopied: Bool {
        copyCount > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            header

            card

            buttons
        }
        .task(id: copyCount) {
            await clearCopiedLater()
        }
        .onChange(of: text) {
            copyCount = 0
        }
        .sensoryFeedback(.success, trigger: copyCount) { _, newValue in
            newValue > 0
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            Text("schedule.send.title")
                .font(.elmsSans(.bold, ScheduleMetrics.Size.fillTitle))
                .foregroundStyle(Color.ink)
                .accessibilityAddTraits(.isHeader)

            MonthHeader(
                title: monthTitle,
                canGoBack: canGoBack,
                canGoForward: true,
                onPrevious: onPrevious,
                onNext: onNext
            )
        }
    }

    @ViewBuilder
    private var card: some View {
        if let text {
            ScrollView {
                Text(verbatim: text)
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.sendText))
                    .foregroundStyle(Color.ink)
                    .lineSpacing(ScheduleMetrics.Spacing.sendLineSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(ScheduleMetrics.Spacing.sendCardPadding)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        textHeight = height
                    }
            }
            .frame(maxHeight: textHeight)
            .opacity(textHeight == nil ? 0 : 1)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .cardSurface(padding: 0, cornerRadius: ScheduleMetrics.Size.sendCardCornerRadius)
        } else {
            Text("schedule.send.empty")
                .font(.elmsSans(.regular, ScheduleMetrics.Size.sendText))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .cardSurface(padding: ScheduleMetrics.Spacing.sendCardPadding, cornerRadius: ScheduleMetrics.Size.sendCardCornerRadius)
        }
    }

    private var buttons: some View {
        HStack(spacing: ScheduleMetrics.Spacing.sendButtonSpacing) {
            CapsuleButton(
                titleKey: isCopied ? "schedule.send.copied" : "schedule.send.copy",
                role: .secondary,
                isEnabled: text != nil,
                fillsWidth: true,
                action: copy
            )

            CapsuleButton(
                titleKey: "schedule.send.send",
                role: .primary,
                isEnabled: text != nil,
                fillsWidth: true,
                action: onSend
            )
        }
    }

    private func copy() {
        copyCount += 1
        onCopy()
    }

    @MainActor
    private func clearCopiedLater() async {
        guard copyCount > 0 else { return }

        do {
            try await Task.sleep(for: .seconds(2))
            copyCount = 0
        } catch {}
    }
}

#if DEBUG
#Preview {
    SendScheduleTextStep(
        monthTitle: "Жовтень 2026",
        canGoBack: false,
        text: SchedulePreviewData.sendSchedule.text,
        onPrevious: {},
        onNext: {},
        onCopy: {},
        onSend: {}
    )
    .padding()
    .background(Color.card)
}
#endif
