import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("master.placeholder.title")
                    .font(.elmsSans(.bold, 24))
                    .foregroundStyle(Color.ink)

                myServicesLink
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var myServicesLink: some View {
        NavigationLink {
            MyServicesView()
        } label: {
            Text("services.action.open")
                .font(.elmsSans(.bold, 14.5))
        }
    }
}

#Preview {
    StatsView()
}
