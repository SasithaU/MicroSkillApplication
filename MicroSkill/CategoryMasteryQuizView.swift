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
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing * 1.5) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(Theme.accent)
                            
                            Text("\(category) Mastery Quiz")
                                .font(Theme.headline())
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        Text("Test your knowledge and earn mastery points!")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, Theme.padding)
                    
                    // Question Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Question")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(quiz.question)
                            .font(Theme.title3())
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .cardStyle()
                    
                    // Answer Options
                    VStack(spacing: 12) {
                        ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedAnswerIndex = index
                                    isCorrect = index == quiz.correctAnswerIndex
                                    showResult = true
                                    
                                    // Mark quiz as used
                                    store.markCategoryMasteryQuizUsed(quiz)
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(Theme.body())
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    if showResult && selectedAnswerIndex == index {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(isCorrect ? Theme.success : Color.red)
                                    } else if !showResult {
                                        Image(systemName: "circle")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .cardStyle()
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                        .stroke(
                                            showResult && selectedAnswerIndex == index 
                                                ? (isCorrect ? Theme.success : Color.red) 
                                                : Theme.primary.opacity(0.1),
                                            lineWidth: 2
                                        )
                                )
                                .opacity(showResult && selectedAnswerIndex != index ? 0.6 : 1.0)
                            }
                            .buttonStyle(.plain)
                            .disabled(showResult)
                        }
                    }
                    
                    // Result Message
                    if showResult {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(isCorrect ? Theme.success : Color.red)
                                
                                Text(isCorrect ? "Correct!" : "Incorrect")
                                    .font(Theme.headline())
                                    .foregroundColor(isCorrect ? Theme.success : Color.red)
                                
                                Spacer()
                            }
                            
                            if !isCorrect {
                                Text("The correct answer is: \(quiz.options[quiz.correctAnswerIndex])")
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("Close") {
                                dismiss()
                            }
                            .buttonStyle(.primary)
                        }
                        .padding()
                        .cardStyle()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)
            }
            .navigationTitle("Mastery Quiz")
            .navigationBarTitleDisplayMode(.inline)
        }
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
