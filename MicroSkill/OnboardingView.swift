import SwiftUI

struct OnboardingView: View {
    @State private var userName = ""
    @State private var selectedGoal = ""
    @State private var hasCompletedOnboarding = false
    let goals = ["Tech Skills", "Productivity", "General Knowledge"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()
                
                ScrollView {
                    VStack(spacing: Theme.spacing * 2.5) {
                        heroSection
                        nameInputSection
                        goalSelectionSection
                        
                        Spacer(minLength: 40)
                        
                        continueButton
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $hasCompletedOnboarding) {
                MainTabView()
                    .navigationBarHidden(true)
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
            
            TextField("Enter your name", text: $userName)
                .font(Theme.body())
                .padding(18)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Theme.primary.opacity(0.1), lineWidth: 1)
                )
        }
    }
    
    private var goalSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's your primary focus?")
                .font(Theme.headline())
                .foregroundColor(.primary)

            Text("We use this to personalize your learning path and recommendations. You can still explore all topics anytime.")
                .font(Theme.caption())
                .foregroundColor(.secondary)
            
            ForEach(goals, id: \.self) { goal in
                GoalButton(goal: goal, isSelected: selectedGoal == goal) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedGoal = goal
                    }
                }
            }
        }
    }
    
    private var continueButton: some View {
        Button {
            guard !userName.isEmpty, !selectedGoal.isEmpty else { return }
            UserDefaults.standard.set(userName, forKey: "userName")
            UserDefaults.standard.set(selectedGoal, forKey: "userGoal")
            UserDefaults.standard.set(true, forKey: "isFirstTimeUser")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hasCompletedOnboarding = true
            }
        } label: {
            HStack(spacing: 12) {
                Text("Start Personalized Path")
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(userName.isEmpty || selectedGoal.isEmpty)
        .opacity(userName.isEmpty || selectedGoal.isEmpty ? 0.6 : 1.0)
    }
}

// MARK: - Goal Button

struct GoalButton: View {
    let goal: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: goalIcon(for: goal))
                    .font(.title2)
                    .foregroundColor(isSelected ? Theme.primary : .secondary)
                    .frame(width: 36, height: 36)
                
                Text(goal)
                    .font(Theme.headline())
                    .foregroundColor(isSelected ? Theme.primary : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.primary)
                        .font(.title3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
        }
        .buttonStyle(SelectionCardStyle(isSelected: isSelected))
    }
    
    func goalIcon(for goal: String) -> String {
        switch goal {
        case "Tech Skills": return "laptopcomputer"
        case "Productivity": return "checkmark.seal.fill"
        case "General Knowledge": return "lightbulb.fill"
        default: return "star.fill"
        }
    }
}

#Preview {
    OnboardingView()
}
