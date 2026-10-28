import SwiftUI
import FirebaseCore

@main
struct YoiApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
