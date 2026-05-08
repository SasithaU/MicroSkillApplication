import SwiftUI

struct CategoryMasteryQuizView: View {
    let quiz: CategoryMasteryQuiz
    let category: String
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAnswerIndex: Int? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Theme.accent.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Theme.accent)
                                    .font(.title3)
                            }
                            
                            Text("\(category) Mastery Quiz")
                                .font(Theme.headline())
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        Text("Earn your mastery badge by completing this challenge!")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Question Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("QUESTION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        Text(quiz.question)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                    .glassCardStyle()
                    
                    // Answer Options
                    VStack(spacing: 14) {
                        ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selectedAnswerIndex = index
                                    isCorrect = index == quiz.correctAnswerIndex
                                    showResult = true
                                    store.markCategoryMasteryQuizUsed(quiz)
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    Text(option)
                                        .font(Theme.body())
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    if showResult && selectedAnswerIndex == index {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(isCorrect ? Theme.success : Color.red)
                                            .symbolEffect(.bounce, value: showResult)
                                    } else {
                                        Circle()
                                            .strokeBorder(Theme.primary.opacity(0.2), lineWidth: 1)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Circle()
                                                    .fill(selectedAnswerIndex == index ? Theme.primary : Color.clear)
                                                    .frame(width: 14, height: 14)
                                            )
                                    }
                                }
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            showResult && selectedAnswerIndex == index 
                                                ? (isCorrect ? Theme.success : Color.red) 
                                                : Color.white.opacity(0.15),
                                            lineWidth: 1.5
                                        )
                                )
                                .opacity(showResult && selectedAnswerIndex != index ? 0.6 : 1.0)
                            }
                            .buttonStyle(.plain)
                            .disabled(showResult)
                            .accessibilityLabel("Option: \(option)")
                            .accessibilityHint("Double tap to select this answer")
                        }
                    }
                    
                    // Result Message
                    if showResult {
                        VStack(spacing: 20) {
                            HStack(spacing: 12) {
                                Image(systemName: isCorrect ? "checkmark.seal.fill" : "exclamationmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(isCorrect ? Theme.success : Color.red)
                                
                                Text(isCorrect ? "Mastery Achieved!" : "Try Again Next Time")
                                    .font(Theme.headline())
                                    .foregroundColor(isCorrect ? Theme.success : Color.red)
                                
                                Spacer()
                            }
                            
                            if !isCorrect {
                                Text("Knowledge builds over time. Review the lessons and try again!")
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("You've demonstrated exceptional understanding of \(category).")
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Continue")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(24)
                        .glassCardStyle()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CategoryMasteryQuizView(
            quiz: CategoryMasteryQuiz(
                category: "Tech",
                question: "What is the primary purpose of SwiftUI's @State property wrapper?",
                options: ["Managing app-wide state", "Managing local view state", "Handling network requests", "Storing user preferences"],
                correctAnswerIndex: 1
            ),
            category: "Tech"
        )
        .environmentObject(DataStore.shared)
    }
}
