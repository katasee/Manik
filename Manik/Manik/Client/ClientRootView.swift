import SwiftUI

struct ClientRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: ClientTab = .booking

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .booking:
                    BookingView(
                        viewModel: BookingViewModel(clientId: profile.uid),
                        clientName: profile.name,
                        bottomClearance: TabBarMetrics.Size.reservedClearance,
                        onBooked: showMyBookings
                    )
                case .myBookings:
                    placeholder
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

    private var placeholder: some View {
        Text("client.placeholder.title")
            .font(.elmsSans(.bold, 24))
            .foregroundStyle(Color.ink)
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
