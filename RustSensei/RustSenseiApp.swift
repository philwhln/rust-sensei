import SwiftUI

@main
struct RustSenseiApp: App {
    @State private var progress = ProgressStore()
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(progress)
                .environment(router)
                .tint(Theme.rust)
        }
    }
}
