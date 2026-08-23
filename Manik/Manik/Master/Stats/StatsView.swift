import SwiftUI

struct StatsView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("master.placeholder.title")
                    .font(.elmsSans(.bold, 24))
                    .foregroundStyle(Color.ink)

                Text(verbatim: profile.name)
                    .font(.elmsSans(.regular, 16))
                    .foregroundStyle(Color.textSecondary)

                myServicesLink

                signOutButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var myServicesLink: some View {
        NavigationLink {
            MyServicesView(viewModel: MyServicesViewModel())
        } label: {
            Text("services.action.open")
                .font(.elmsSans(.bold, 14.5))
        }
    }

    private var signOutButton: some View {
        Button("common.action.signOut", action: onSignOut)
            .font(.elmsSans(.bold, 14.5))
    }
}

#Preview {
    StatsView(
        profile: UserProfile(uid: "preview", role: .master, name: "Марина", email: "master@example.com"),
        onSignOut: {}
    )
}
