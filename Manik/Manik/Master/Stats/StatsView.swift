import SwiftUI

struct StatsView: View {
    @State private var viewModel: StatsViewModel
    @State private var path: [StatsRoute] = []

    private let profile: UserProfile
    private let onSignOut: () -> Void
    private let onAccountDeleted: () -> Void

    init(
        viewModel: StatsViewModel,
        profile: UserProfile,
        onSignOut: @escaping () -> Void,
        onAccountDeleted: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.profile = profile
        self.onSignOut = onSignOut
        self.onAccountDeleted = onAccountDeleted
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                LargeTitleHeader(titleKey: "stats.title") {
                    RoundIconButton(
                        systemImage: "person.crop.circle",
                        accessibilityLabel: "profile.action.open",
                        action: showProfile
                    )
                }

                monthRow

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StatsRoute.self) { route in
                switch route {
                case .services:
                    MyServicesView(viewModel: MyServicesViewModel())
                case .profile:
                    ProfileView(
                        profile: profile,
                        onSignOut: onSignOut,
                        onAccountDeleted: onAccountDeleted
                    )
                }
            }
            .task {
                await viewModel.observeBlocks()
            }
            .task {
                await viewModel.refreshStats()
            }
        }
    }

    private func showProfile() {
        path.append(.profile)
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
            value: viewModel.stats.visitsLabel,
            titleKey: "stats.card.visits"
        )
    }

    private var hoursCard: some View {
        StatCard(
            iconName: "clock",
            value: viewModel.stats.hoursLabel,
            unitKey: "stats.hours.unit",
            titleKey: "stats.card.hours"
        )
    }

    private var clientsCard: some View {
        StatCard(
            iconName: "person.2",
            value: viewModel.stats.clientsLabel,
            titleKey: "stats.card.clients",
            trend: viewModel.stats.clientsTrend
        )
    }

    private var slotsCard: some View {
        StatCard(
            iconName: "square.dashed",
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
            route: .services
        )
    }
}

#if DEBUG
#Preview("Статистика") {
    StatsView(
        viewModel: StatsViewModel(
            blockRepository: FakeBlockRepository(blocks: StatsPreviewData.blocks)
        ),
        profile: ProfilePreviewData.profile,
        onSignOut: {},
        onAccountDeleted: {}
    )
}

#Preview("Порожній місяць") {
    StatsView(
        viewModel: StatsViewModel(
            blockRepository: FakeBlockRepository(blocks: StatsPreviewData.emptyMonth)
        ),
        profile: ProfilePreviewData.profile,
        onSignOut: {},
        onAccountDeleted: {}
    )
}
#endif
