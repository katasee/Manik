import SwiftUI

struct ClientRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    @State private var selectedTab: ClientTab = .booking

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                Text("client.placeholder.title")
                    .font(.elmsSans(.bold, 24))
                    .foregroundStyle(Color.textPrimary)

                Text(selectedTab.titleKey)
                    .font(.elmsSans(.medium, 16))
                    .foregroundStyle(Color.textSecondary)

                Text(profile.name)
                    .font(.elmsSans(.regular, 16))
                    .foregroundStyle(Color.textSecondary)

                Button(action: onSignOut) {
                    Text("common.action.signOut")
                        .font(.elmsSans(.bold, 14.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)

            CustomTabBar(kind: .client(selection: $selectedTab))
        }
    }
}

#Preview {
    ClientRootView(
        profile: UserProfile(uid: "preview", role: .client, name: "Оля", email: "client@example.com"),
        onSignOut: {}
    )
}
