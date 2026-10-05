import SwiftUI

struct StatsView: View {
    @State private var viewModel: StatsViewModel

    private let onSignOut: () -> Void

    init(viewModel: StatsViewModel, onSignOut: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignOut = onSignOut
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenHeader(titleKey: "stats.title")

                monthRow

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StatsRoute.self) { _ in
                MyServicesView(viewModel: MyServicesViewModel())
            }
            .task {
                await viewModel.observeBlocks()
            }
            .task {
                await viewModel.refreshStats()
            }
        }
    }

    private var monthRow: some View {
        MonthHeader(
            title: viewModel.monthTitle,
            canGoBack: true,
            canGoForward: viewModel.canGoForward,
            onPrevious: viewModel.showPreviousMonth,
            onNext: viewModel.showNextMonth
        )
        .padding(.horizontal, StatsMetrics.Spacing.horizontalPadding)
        .padding(.top, StatsMetrics.Spacing.monthTopPadding)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: StatsMetrics.Spacing.cardSpacing) {
                RevenueCard(stats: viewModel.stats)

                Grid(
                    horizontalSpacing: StatsMetrics.Spacing.cardSpacing,
                    verticalSpacing: StatsMetrics.Spacing.cardSpacing
                ) {
                    GridRow {
                        visitsCard
                        hoursCard
                    }

                    GridRow {
                        clientsCard
                        slotsCard
                    }
                }

                servicesLink

                signOutButton
            }
            .padding(.horizontal, StatsMetrics.Spacing.horizontalPadding)
            .padding(.top, StatsMetrics.Spacing.contentTopPadding)
            .padding(.bottom, StatsMetrics.Spacing.contentBottomPadding)
        }
        .scrollIndicators(.hidden)
        .overlay {
            if viewModel.hasLoaded == false {
                ProgressView()
                    .tint(Color.ink)
            }
        }
    }

    private var visitsCard: some View {
        StatCard(
            iconName: "checkmark.circle",
            tint: Color.statusConfirmed,
            value: viewModel.stats.visitsLabel,
            titleKey: "stats.card.visits"
        )
    }

    private var hoursCard: some View {
        StatCard(
            iconName: "clock",
            tint: Color.statusPending,
            value: viewModel.stats.hoursLabel,
            unitKey: "stats.hours.unit",
            titleKey: "stats.card.hours"
        )
    }

    private var clientsCard: some View {
        StatCard(
            iconName: "person.2",
            tint: Color.freeSlot,
            value: viewModel.stats.clientsLabel,
            titleKey: "stats.card.clients",
            trend: viewModel.stats.clientsTrend
        )
    }

    private var slotsCard: some View {
        StatCard(
            iconName: "square.dashed",
            tint: Color.statusAvailable,
            value: viewModel.stats.freeSlotsLabel,
            titleKey: viewModel.stats.isMonthFinished
                ? "stats.card.unbookedSlots"
                : "stats.card.freeSlots"
        )
    }

    private var servicesLink: some View {
        StatsLinkRow(
            titleKey: "services.action.open",
            iconName: "list.bullet.rectangle",
            tint: Color.statusPending,
            route: .services
        )
    }

    private var signOutButton: some View {
        Button("common.action.signOut", action: onSignOut)
            .font(.elmsSans(.medium, 14.5))
            .foregroundStyle(Color.textSecondary)
            .padding(.top, StatsMetrics.Spacing.signOutTopPadding)
    }
}

#if DEBUG
#Preview("Статистика") {
    StatsView(
        viewModel: StatsViewModel(
            blockRepository: FakeBlockRepository(blocks: StatsPreviewData.blocks)
        ),
        onSignOut: {}
    )
}

#Preview("Порожній місяць") {
    StatsView(
        viewModel: StatsViewModel(
            blockRepository: FakeBlockRepository(blocks: StatsPreviewData.emptyMonth)
        ),
        onSignOut: {}
    )
}
#endif
