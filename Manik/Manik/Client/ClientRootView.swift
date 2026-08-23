import SwiftUI

struct ClientRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: ClientTab = .booking
    @State private var bookingViewModel: BookingViewModel
    @State private var myBookingsViewModel: MyBookingsViewModel

    init(profile: UserProfile, onSignOut: @escaping () -> Void) {
        self.profile = profile
        self.onSignOut = onSignOut
        _bookingViewModel = State(initialValue: BookingViewModel(clientId: profile.uid))
        _myBookingsViewModel = State(initialValue: MyBookingsViewModel(clientId: profile.uid))
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
                    account
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

    private var account: some View {
        VStack(spacing: 16) {
            Text(profile.name)
                .font(.elmsSans(.bold, 24))
                .foregroundStyle(Color.ink)

            Text(profile.email)
                .font(.elmsSans(.regular, 16))
                .foregroundStyle(Color.textSecondary)

            Button(action: onSignOut) {
                Text("common.action.signOut")
                    .font(.elmsSans(.bold, 14.5))
                    .foregroundStyle(Color.ink)
            }
        }
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
        onSignOut: {}
    )
}
#endif
