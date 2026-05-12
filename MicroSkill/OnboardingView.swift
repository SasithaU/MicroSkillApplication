import SwiftUI

struct OnboardingView: View {
    @AppStorage("isFirstTimeUser", store: UserDefaults(suiteName: "group.com.microskill.app")) private var hasCompletedOnboarding = false
    @State private var localName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                
                ScrollView {
                    VStack(spacing: Theme.spacing * 2.5) {
                        heroSection
                        nameInputSection
                        
                        Spacer(minLength: 40)
                        
                        continueButton
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.12))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .foregroundStyle(Theme.primary)
            }
            
            Text("Welcome to\nMicroSkill")
                .font(Theme.title())
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text("Let's personalize your learning journey")
                .font(Theme.body())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
    
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What should we call you?")
                .font(Theme.headline())
                .foregroundColor(.primary)
            
            TextField("Enter your name", text: $localName)
                .font(Theme.body())
                .padding(18)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.primary.opacity(0.1), lineWidth: 1)
                )
        }
    }
    

    
    private var continueButton: some View {
        Button {
            guard !localName.isEmpty else { return }
            DataStore.shared.updateProfile(name: localName, imageData: nil)
            BiometricAuthManager.shared.authenticateManually()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hasCompletedOnboarding = true
            }
        } label: {
            HStack(spacing: 12) {
                Text("Continue to Subject Selection")
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(localName.isEmpty)
        .opacity(localName.isEmpty ? 0.6 : 1.0)
    }
}



#Preview {
    OnboardingView()
}
