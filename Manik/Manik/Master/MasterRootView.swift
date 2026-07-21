import SwiftUI

struct MasterRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("master.placeholder.title")
                .font(.elmsSans(.bold, 24))
                .foregroundStyle(Color.textPrimary)

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
    }
}

#Preview {
    MasterRootView(
        profile: UserProfile(uid: "preview", role: .master, name: "Марина", email: "master@example.com"),
        onSignOut: {}
    )
}
