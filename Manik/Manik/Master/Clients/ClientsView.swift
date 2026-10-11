import SwiftUI

struct ClientsView: View {
    @Binding var query: String
    let items: [ClientItem]
    let totalCount: Int
    let hasLoaded: Bool
    let onAdd: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LargeTitleHeader(titleKey: "clients.title", subtitle: subtitle) {
                    RoundIconButton(
                        systemImage: "plus",
                        accessibilityLabel: "clients.action.add",
                        action: onAdd
                    )
                }

                SearchField(text: $query, placeholderKey: "clients.search.placeholder")
                    .padding(.horizontal, ClientsMetrics.Spacing.horizontalPadding)
                    .padding(.top, ClientsMetrics.Spacing.searchTopPadding)

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var subtitle: String? {
        hasLoaded ? String(localized: "clients.count \(totalCount)") : nil
    }

    private var isBaseEmpty: Bool {
        totalCount == 0
    }

    private var content: some View {
        ZStack {
            if items.isEmpty == false {
                list
            }

            ListStatusOverlay(
                hasLoaded: hasLoaded,
                isEmpty: items.isEmpty,
                titleKey: isBaseEmpty ? "clients.empty.title" : "clients.search.empty.title",
                messageKey: isBaseEmpty ? "clients.empty.message" : "clients.search.empty.message"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: ClientsMetrics.Spacing.rowSpacing) {
                if query.isEmpty {
                    SectionLabel(titleKey: "clients.section.recent")
                        .padding(.horizontal, ClientsMetrics.Spacing.sectionLabelInset)
                }

                ForEach(items) { item in
                    ClientRow(item: item)
                }
            }
            .padding(.horizontal, ClientsMetrics.Spacing.horizontalPadding)
            .padding(.top, ClientsMetrics.Spacing.listTopPadding)
            .padding(.bottom, ClientsMetrics.Spacing.listBottomPadding)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var query = ""

    ClientsView(
        query: $query,
        items: ClientsPreviewData.clients.map(ClientItem.init),
        totalCount: ClientsPreviewData.clients.count,
        hasLoaded: true,
        onAdd: {}
    )
}
#endif
