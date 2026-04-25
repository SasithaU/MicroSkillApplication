import SwiftUI

@main
struct MicroSkillApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(DataStore.shared)
        }
    }
}
