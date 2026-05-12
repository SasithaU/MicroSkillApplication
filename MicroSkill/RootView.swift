import SwiftUI

struct RootView: View {
    @AppStorage("isFirstTimeUser", store: UserDefaults(suiteName: "group.com.microskill.app")) private var hasCompletedOnboarding = false
    @AppStorage("appAccessibilityHighContrast", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityHighContrast = false
    @AppStorage("appAccessibilityReduceTransparency", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityReduceTransparency = false
    @AppStorage("appAccessibilityReduceMotion", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityReduceMotion = false
    @AppStorage("appAccessibilityDifferentiateWithoutColor", store: UserDefaults(suiteName: "group.com.microskill.app")) private var appAccessibilityDifferentiateWithoutColor = false
    @StateObject private var authManager = BiometricAuthManager.shared
    @EnvironmentObject var store: DataStore
    @State private var isShowingSplash = true
    
    var body: some View {
        let appAccessibility = AppAccessibilitySettings(
            highContrast: appAccessibilityHighContrast,
            reduceTransparency: appAccessibilityReduceTransparency,
            reduceMotion: appAccessibilityReduceMotion,
            differentiateWithoutColor: appAccessibilityDifferentiateWithoutColor
        )

        ZStack {
            if !store.isDataInitialized {
                SplashView()
            } else if !hasCompletedOnboarding {
                OnboardingView()
            } else if store.activeSubject == nil {
                SubjectInputView()
            } else if !authManager.isAuthenticated {
                BiometricAuthView()
                    .environmentObject(authManager)
            } else {
                MainTabView()
                    .onAppear {
                        NotificationManager.shared.checkAuthorization()
                    }
            }
            
            // Global Error Overlay
            if let error = store.errorMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text(error)
                            .font(Theme.caption())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Button(action: { store.errorMessage = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.9))
                    .cornerRadius(12)
                    .padding()
                    .premiumShadow()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.spring(), value: store.errorMessage)
        .environment(\.appAccessibilitySettings, appAccessibility)
    }
}

struct BiometricAuthView: View {
    @EnvironmentObject var authManager: BiometricAuthManager
    @EnvironmentObject var store: DataStore
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
                    Text("Welcome back, \(store.progress.userName ?? "Learner")")
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
        .onAppear {
            // Automatically trigger biometric auth if enabled
            if authManager.isBiometricAuthEnabled {
                // Small delay to ensure view is fully transitioned
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authManager.authenticate()
                }
            }
        }
    }
}

// Subject Selection View for Goal-Driven Learning
struct SubjectInputView: View {
    @EnvironmentObject var store: DataStore
    @State private var subjectText: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 40) {
                // Profile Toolbar
                HStack {
                    NavigationLink(destination: ProfileView()) {
                        Group {
                            if let data = store.progress.profileImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.primary, lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Theme.primary)
                                    .padding(8)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                        }
                        .premiumShadow()
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
                Spacer()
                
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .blur(radius: 15)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.heroGradient)
                            .premiumShadow()
                    }
                    
                    Text("What do you want to master today?")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.horizontal, 20)
                    
                    Text("Enter any field of study, and we'll create a personalized path for you.")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                if store.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Architecting your personalized curriculum...")
                            .font(Theme.caption())
                            .foregroundColor(Theme.primary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Input Field
                    VStack(spacing: 12) {
                        if let error = store.errorMessage {
                            Text(error)
                                .font(Theme.caption())
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 8)
                        }
                        
                        TextField("e.g., Quantum Physics, SwiftUI, Cooking", text: $subjectText)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(isInputFocused ? Theme.primary : Color.white.opacity(0.2), lineWidth: 2)
                            )
                            .focused($isInputFocused)
                            .premiumShadow()
                            .onSubmit(startJourney)
                        
                        if !subjectText.isEmpty {
                            Text("Ready to learn about \(subjectText)?")
                                .font(Theme.caption())
                                .foregroundColor(Theme.primary)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                    
                    // Action
                    Button(action: startJourney) {
                        HStack {
                            Text("Begin Your Journey")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, Theme.padding)
                    .disabled(subjectText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(subjectText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                }
                
                Spacer()
                
                // Suggestions
                VStack(spacing: 12) {
                    Text("POPULAR TOPICS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        suggestionTag("Machine Learning")
                        suggestionTag("Ancient History")
                        suggestionTag("Digital Art")
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    private func suggestionTag(_ text: String) -> some View {
        Button {
            subjectText = text
        } label: {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func startJourney() {
        guard !subjectText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation(.spring()) {
            store.setActiveSubject(subjectText)
        }
    }
}

