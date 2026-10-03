import SwiftUI

struct ClientRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void
    let onProfileUpdated: (UserProfile) -> Void

    @State private var selectedTab: ClientTab = .booking
    @State private var bookingViewModel: BookingViewModel
    @State private var myBookingsViewModel: MyBookingsViewModel
    @State private var accountViewModel: AccountViewModel

    init(
        profile: UserProfile,
        onSignOut: @escaping () -> Void,
        onProfileUpdated: @escaping (UserProfile) -> Void
    ) {
        self.profile = profile
        self.onSignOut = onSignOut
        self.onProfileUpdated = onProfileUpdated
        _bookingViewModel = State(initialValue: BookingViewModel(clientId: profile.uid))
        _myBookingsViewModel = State(initialValue: MyBookingsViewModel(clientId: profile.uid))
        _accountViewModel = State(
            initialValue: AccountViewModel(
                profile: profile,
                onProfileUpdated: onProfileUpdated
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .booking:
                    BookingView(
                        viewModel: bookingViewModel,
                        clientName: profile.name,
                        bottomClearance: TabBarMetrics.Size.reservedClearance,
                        onBooked: showMyBookings
                    )
                case .myBookings:
                    MyBookingsView(viewModel: myBookingsViewModel)
                case .account:
                    AccountView(viewModel: accountViewModel, onSignOut: onSignOut)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: TabBarMetrics.Size.reservedClearance)
            }

            CustomTabBar(kind: .client(selection: $selectedTab))
        }
    }

    private func showMyBookings() {
        selectedTab = .myBookings
    }

}

#if DEBUG
#Preview {
    ClientRootView(
        profile: UserProfile(
            uid: "preview",
            role: .client,
            name: "Олена",
            email: "client@example.com"
        ),
        onSignOut: {},
        onProfileUpdated: { _ in }
    )
}
#endif
