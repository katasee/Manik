import SwiftUI

enum FillMonthTab: CaseIterable, Identifiable {
    case slots
    case plans

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .slots: "schedule.tab.slots"
        case .plans: "schedule.tab.plans"
        }
    }
}

private struct FillMonthTabLens: View {
    var body: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(.regular, in: .capsule)
        } else {
            Capsule()
                .fill(Color.raised)
                .strokeBorder(Color.hairline)
                .brandShadow()
        }
    }
}

struct FillMonthTabs: View {
    @Binding var selection: FillMonthTab

    @Namespace private var lens

    var body: some View {
        if #available(iOS 26, *) {
            track
                .glassEffect(.regular, in: .capsule)
        } else {
            track
                .raisedSurface(.capsule)
        }
    }

    private var track: some View {
        HStack(spacing: ScheduleMetrics.Spacing.tabTrackPadding) {
            ForEach(FillMonthTab.allCases) { tab in
                Button {
                    select(tab)
                } label: {
                    Text(tab.titleKey)
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.tabTitle))
                        .foregroundStyle(tab == selection ? Color.ink : Color.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.tabHeight)
                        .background {
                            if tab == selection {
                                FillMonthTabLens()
                                    .matchedGeometryEffect(id: "lens", in: lens)
                            }
                        }
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(tab == selection ? .isSelected : [])
            }
        }
        .padding(ScheduleMetrics.Spacing.tabTrackPadding)
    }

    private func select(_ tab: FillMonthTab) {
        withAnimation(.snappy) {
            selection = tab
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection = FillMonthTab.plans

    FillMonthTabs(selection: $selection)
        .padding()
        .background(Color.card)
}
#endif
