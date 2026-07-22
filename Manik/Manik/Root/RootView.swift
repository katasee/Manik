import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .signedOut:
                VStack(spacing: 0) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.elmsSans(.regular, 13))
                            .foregroundStyle(.red)
                            .padding()
                    }
                    AuthView {
                        await viewModel.refresh()
                    }
                }
            case .signedIn(let profile):
                switch profile.role {
                case .master:
                    MasterRootView(profile: profile, onSignOut: viewModel.signOut)
                case .client:
                    ClientRootView(profile: profile, onSignOut: viewModel.signOut)
                }
            }
        }
        .task {
            await viewModel.refresh()
        }
    }
}

#Preview {
    RootView()
}
