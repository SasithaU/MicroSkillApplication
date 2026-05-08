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
            PremiumBackground()
            
            VStack(spacing: 32) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Theme.heroGradient)
                        .premiumShadow()
                }
                
                VStack(spacing: 12) {
                    Text("Secure Access")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Authenticate with \(authManager.biometricType) to unlock your learning journey.")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                if let error = authManager.authError {
                    Text(error)
                        .font(Theme.caption())
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                }
                
                Button {
                    authManager.authenticate()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: authManager.biometricIconName)
                        Text("Unlock with \(authManager.biometricType)")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 40)
                .accessibilityLabel("Authenticate with \(authManager.biometricType)")
                .accessibilityHint("Double tap to unlock the app.")
                
                Spacer()
            }
        }
    }
}
