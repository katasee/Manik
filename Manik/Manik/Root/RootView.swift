import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()
    @AppStorage(AppAppearance.storageKey) private var appearance: AppAppearance = .system

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
                MasterRootView(onSignOut: viewModel.signOut)
                    .id(profile.uid)
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .task {
            await viewModel.refresh()
        }
    }
}

#Preview {
    RootView()
}
