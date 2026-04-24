import SwiftUI

struct RootView: View {
    @AppStorage("isFirstTimeUser") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            SplashView()
        }
    }
}
