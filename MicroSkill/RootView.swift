import SwiftUI

struct RootView: View {
    @AppStorage("isFirstTimeUser") private var hasCompletedOnboarding = false
    @StateObject private var authManager = BiometricAuthManager.shared
    
    var body: some View {
        if hasCompletedOnboarding {
            if authManager.isAuthenticated || !authManager.canAuthenticate {
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
                
                Text("Secure Access")
                    .font(Theme.largeTitle())
                    .foregroundColor(.primary)
                
                Text("Authenticate with \(authManager.biometricType) to access your learning progress.")
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                if let error = authManager.authError {
                    Text(error)
                        .font(Theme.caption())
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button {
                    authManager.authenticate()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
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
                
                Spacer()
            }
        }
    }
}
