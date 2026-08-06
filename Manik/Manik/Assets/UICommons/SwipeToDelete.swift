import SwiftUI

private enum SwipeToDeleteLayout {
    static let actionWidth: CGFloat = 72
    static let iconSize: CGFloat = 22
    static let openThreshold: CGFloat = 36
    static let minimumDrag: CGFloat = 12
    static let snap = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let reducedMotionSnap = Animation.easeOut(duration: 0.15)
}

struct SwipeToDelete<Content: View>: View {
    let id: String
    @Binding var openId: String?
    let cornerRadius: CGFloat
    let onDelete: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var offsetX: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteAction
            content
                .offset(x: offsetX)
                .simultaneousGesture(dragGesture)
        }
        .background(
            Color.destructive.opacity(isRevealed ? 1 : 0),
            in: .rect(cornerRadius: cornerRadius)
        )
        .clipShape(.rect(cornerRadius: cornerRadius))
        .onChange(of: openId) {
            withAnimation(snap) {
                offsetX = restingOffset
            }
        }
    }

    private var deleteAction: some View {
        Button(action: delete) {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(
                    width: SwipeToDeleteLayout.iconSize,
                    height: SwipeToDeleteLayout.iconSize
                )
                .foregroundStyle(Color.fieldBackground)
                .frame(width: SwipeToDeleteLayout.actionWidth)
                .frame(maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .opacity(isRevealed ? 1 : 0)
        .accessibilityHidden(isRevealed == false)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: SwipeToDeleteLayout.minimumDrag)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                offsetX = clamped(restingOffset + value.translation.width)
            }
            .onEnded { value in
                let released = clamped(restingOffset + value.translation.width)
                let shouldOpen = released < -SwipeToDeleteLayout.openThreshold

                withAnimation(snap) {
                    offsetX = shouldOpen ? -SwipeToDeleteLayout.actionWidth : 0
                }

                openId = shouldOpen ? id : nil
            }
    }

    private var isOpen: Bool {
        openId == id
    }

    private var isRevealed: Bool {
        offsetX < 0
    }

    private var restingOffset: CGFloat {
        isOpen ? -SwipeToDeleteLayout.actionWidth : 0
    }

    private var snap: Animation {
        reduceMotion ? SwipeToDeleteLayout.reducedMotionSnap : SwipeToDeleteLayout.snap
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        min(max(value, -SwipeToDeleteLayout.actionWidth), 0)
    }

    private func delete() {
        openId = nil
        onDelete()
    }
}

#Preview {
    @Previewable @State var openId: String?

    SwipeToDelete(id: "preview", openId: $openId, cornerRadius: 18, onDelete: {}) {
        Text("Swipe me")
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color.fieldBackground, in: .rect(cornerRadius: 18))
    }
    .padding()
    .background(Color.background)
}
