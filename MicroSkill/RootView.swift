import SwiftUI

struct RootView: View {
    @AppStorage("isFirstTimeUser") private var hasCompletedOnboarding = false
    @AppStorage("appAccessibilityHighContrast") private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency") private var appAccessibilityReduceTransparency = false
    @AppStorage("appAccessibilityReduceMotion") private var appAccessibilityReduceMotion = false
    @AppStorage("appAccessibilityDifferentiateWithoutColor") private var appAccessibilityDifferentiateWithoutColor = false
    @StateObject private var authManager = BiometricAuthManager.shared
    
    var body: some View {
        let appAccessibility = AppAccessibilitySettings(
            highContrast: appAccessibilityHighContrast,
            reduceTransparency: appAccessibilityReduceTransparency,
            reduceMotion: appAccessibilityReduceMotion,
            differentiateWithoutColor: appAccessibilityDifferentiateWithoutColor
        )

        Group {
            if hasCompletedOnboarding {
                if authManager.isAuthenticated {
                    MainTabView()
                        .onAppear {
                            DataStore.shared.loadData()
                            NotificationManager.shared.checkAuthorization()
                        }
                } else {
                    BiometricAuthView()
                        .environmentObject(authManager)
                }
            } else {
                SplashView()
            }
        }
        .environment(\.appAccessibilitySettings, appAccessibility)
    }
}

struct BiometricAuthView: View {
    @EnvironmentObject var authManager: BiometricAuthManager
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Theme.primary)
                    .accessibilityHidden(true)
                
                Text("Secure Access")
                    .font(Theme.largeTitle())
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Authenticate with \(authManager.biometricType) to access your learning progress.")
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .accessibilityLabel("Authenticate to access your learning progress.")
                
                if let error = authManager.authError {
                    Text(error)
                        .font(Theme.caption())
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .accessibilityLabel("Authentication error. \(error)")
                }
                
                Button {
                    authManager.authenticate()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: authManager.biometricIconName)
                            .font(.title3)
                        Text("Authenticate with \(authManager.biometricType)")
                            .font(Theme.headline())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.controlCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.padding)
                .accessibilityLabel("Authenticate with \(authManager.biometricType)")
                .accessibilityHint("Double tap to unlock the app.")
                
                Spacer()
            }
        }
    }
}
