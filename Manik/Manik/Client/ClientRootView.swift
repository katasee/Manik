import SwiftUI

struct ClientRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void
    let onProfileUpdated: (UserProfile) -> Void
    let onAccountDeleted: () -> Void

    @State private var selectedTab: ClientTab = .booking
    @State private var bookingViewModel: BookingViewModel
    @State private var myBookingsViewModel: MyBookingsViewModel
    @State private var accountViewModel: AccountViewModel

    init(
        profile: UserProfile,
        onSignOut: @escaping () -> Void,
        onProfileUpdated: @escaping (UserProfile) -> Void,
        onAccountDeleted: @escaping () -> Void
    ) {
        self.profile = profile
        self.onSignOut = onSignOut
        self.onProfileUpdated = onProfileUpdated
        self.onAccountDeleted = onAccountDeleted
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
        TabView(selection: $selectedTab) {
            ForEach(ClientTab.allCases) { tab in
                Tab(
                    tab.titleKey,
                    systemImage: tab.systemImage,
                    value: tab
                ) {
                    switch tab {
                    case .booking:
                        BookingView(
                            viewModel: bookingViewModel,
                            clientName: profile.name,
                            onBooked: showMyBookings
                        )
                    case .myBookings:
                        MyBookingsView(viewModel: myBookingsViewModel)
                    case .account:
                        AccountView(
                            viewModel: accountViewModel,
                            onSignOut: onSignOut,
                            onAccountDeleted: onAccountDeleted
                        )
                    }
                }
            }
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
        onProfileUpdated: { _ in },
        onAccountDeleted: {}
    )
}
#endif
