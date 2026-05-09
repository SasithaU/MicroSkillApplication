import SwiftUI

struct RootView: View {
    @AppStorage("isFirstTimeUser") private var hasCompletedOnboarding = false
    @AppStorage("appAccessibilityHighContrast") private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency") private var appAccessibilityReduceTransparency = false
    @AppStorage("appAccessibilityReduceMotion") private var appAccessibilityReduceMotion = false
    @AppStorage("appAccessibilityDifferentiateWithoutColor") private var appAccessibilityDifferentiateWithoutColor = false
    @StateObject private var authManager = BiometricAuthManager.shared
    @State private var isShowingSplash = true
    
    var body: some View {
        let appAccessibility = AppAccessibilitySettings(
            highContrast: appAccessibilityHighContrast,
            reduceTransparency: appAccessibilityReduceTransparency,
            reduceMotion: appAccessibilityReduceMotion,
            differentiateWithoutColor: appAccessibilityDifferentiateWithoutColor
        )

        Group {
            if isShowingSplash {
                SplashView {
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            } else if !hasCompletedOnboarding {
                OnboardingView()
            } else if !authManager.isAuthenticated {
                BiometricAuthView()
                    .environmentObject(authManager)
            } else {
                    MainTabView()
                        .onAppear {
                            DataStore.shared.loadData()
                            NotificationManager.shared.checkAuthorization()
                        }
                }
            }
            .environment(\.appAccessibilitySettings, appAccessibility)
    }
}

struct BiometricAuthView: View {
    @EnvironmentObject var authManager: BiometricAuthManager
    @AppStorage("userName") private var userName = "User"
    @State private var showingResetAlert = false
    
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
                    
                    AppLogo.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .premiumShadow()
                }
                
                VStack(spacing: 12) {
                    Text("Welcome back, \(userName)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(authManager.isBiometricAuthEnabled ? "Unlock with \(authManager.biometricType) to continue your learning journey." : "Tap below to continue your learning journey.")
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
                
                VStack(spacing: 16) {
                    Button {
                        if authManager.isBiometricAuthEnabled {
                            authManager.authenticate()
                        } else {
                            authManager.authenticateManually()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if authManager.isBiometricAuthEnabled {
                                Image(systemName: authManager.biometricIconName)
                                Text("Unlock with \(authManager.biometricType)")
                            } else {
                                Text("Continue Learning")
                                Image(systemName: "arrow.right.circle.fill")
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)
                    .accessibilityLabel(authManager.isBiometricAuthEnabled ? "Authenticate with \(authManager.biometricType)" : "Continue Learning")
                    
                    Button {
                        showingResetAlert = true
                    } label: {
                        Text("Not you? Reset Journey")
                            .font(Theme.caption())
                            .foregroundColor(.secondary)
                            .underline()
                    }
                    .alert("Reset Journey", isPresented: $showingResetAlert) {
                        Button("Reset Everything", role: .destructive) {
                            authManager.resetAllData()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will clear your name, goals, and all learning progress. This action cannot be undone.")
                    }
                }
                
                Spacer()
            }
        }
    }
}
