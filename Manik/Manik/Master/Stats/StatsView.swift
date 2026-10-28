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
                case .plans:
                    MyPlansView(viewModel: MyPlansViewModel())
                case .profile:
                    ProfileView(
                        profile: profile,
                        onSignOut: onSignOut,
                        onAccountDeleted: onAccountDeleted
                    )
                }
            }
            .task {
                await viewModel.observeSlots()
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
            canGoBack: viewModel.canGoBack,
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
                        clientsCard
                    }

                    GridRow {
                        occupancyCard
                        slotsCard
                    }
                }

                servicesLink
                plansLink
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

    private var clientsCard: some View {
        StatCard(
            iconName: "person.2",
            value: viewModel.stats.clientsLabel,
            titleKey: "stats.card.clients",
            trend: viewModel.stats.clientsTrend
        )
    }

    private var occupancyCard: some View {
        StatCard(
            iconName: "chart.pie",
            value: viewModel.stats.occupancyLabel,
            titleKey: "stats.card.occupancy"
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

    private var plansLink: some View {
        StatsLinkRow(
            titleKey: "plans.action.open",
            iconName: "checklist",
            route: .plans
        )
    }
}

#if DEBUG
#Preview {
    StatsView(
        viewModel: StatsViewModel(
            slotRepository: FakeSlotRepository(slots: StatsPreviewData.slots)
        ),
        profile: ProfilePreviewData.profile,
        onSignOut: {},
        onAccountDeleted: {}
    )
}
#endif
