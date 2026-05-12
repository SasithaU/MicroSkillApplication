import SwiftUI

// Final Subject Selection View for Goal-Driven Learning
struct SubjectInputView: View {
    @EnvironmentObject var store: DataStore
    @State private var subjectText: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 40) {
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
                        .padding(.horizontal, 20)
                    
                    Text("Enter any field of study, and we'll create a personalized path for you.")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Input Field
                VStack(spacing: 12) {
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

#Preview {
    SubjectInputView()
        .environmentObject(DataStore.shared)
}
