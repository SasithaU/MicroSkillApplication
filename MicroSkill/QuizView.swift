import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    let lesson: Lesson
    @EnvironmentObject var store: DataStore
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing * 1.5) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quiz")
                            .font(Theme.caption())
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(quiz.question)
                            .font(Theme.headline())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                        QuizOptionButton(
                                option: option,
                                index: index,
                                selectedIndex: selectedIndex,
                                showResult: showResult,
                                correctIndex: quiz.correctAnswerIndex
                            ) {
                                if !showResult {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedIndex = index
                                    }
                                }
                            }
                            .accessibilityLabel("Option \(String(Character(UnicodeScalar(65 + index)!))): \(option)")
                            .accessibilityHint("Double tap to select this answer")
                        }
                    }
                    
                    // Submit
                    Button {
                        showResult = true
                    } label: {
                        HStack(spacing: 10) {
                            Text("Submit Answer")
                                .font(Theme.headline())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedIndex == nil ? Color.secondary.opacity(0.2) : Theme.primary)
                        .foregroundColor(selectedIndex == nil ? .secondary : .white)
                        .cornerRadius(Theme.cardCornerRadius)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedIndex == nil)
                    .accessibilityLabel("Submit answer")
                    .accessibilityHint(selectedIndex == nil ? "Select an answer first" : "Double tap to submit your answer")
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showResult) {
            QuizResultView(
                isCorrect: selectedIndex == quiz.correctAnswerIndex,
                lesson: lesson,
                correctAnswer: quiz.options[quiz.correctAnswerIndex]
            )
        }
    }
}

// MARK: - Quiz Option Button

struct QuizOptionButton: View {
    let option: String
    let index: Int
    let selectedIndex: Int?
    let showResult: Bool
    let correctIndex: Int
    let action: () -> Void
    
    private var isSelected: Bool { selectedIndex == index }
    private var isCorrect: Bool { index == correctIndex }
    private var state: OptionState {
        if !showResult {
            return isSelected ? .selected : .default
        }
        if isCorrect { return .correct }
        if isSelected && !isCorrect { return .wrong }
        return .default
    }
    
    enum OptionState {
        case `default`, selected, correct, wrong
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(state == .correct ? Theme.success.opacity(0.15) :
                              state == .wrong ? Color.red.opacity(0.15) :
                              state == .selected ? Theme.primary.opacity(0.15) :
                              Color.secondary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Text("\(String(Character(UnicodeScalar(65 + index)!)))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(state == .correct ? Theme.success :
                                        state == .wrong ? .red :
                                        state == .selected ? Theme.primary : .secondary)
                }
                
                Text(option)
                    .font(Theme.body())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if state == .selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.primary)
                } else if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.success)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(state == .selected ? Theme.primary.opacity(0.08) :
                          state == .correct ? Theme.success.opacity(0.08) :
                          state == .wrong ? Color.red.opacity(0.08) :
                          Theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(state == .selected ? Theme.primary.opacity(0.3) :
                            state == .correct ? Theme.success.opacity(0.4) :
                            state == .wrong ? Color.red.opacity(0.4) :
                            Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }
}

#Preview {
    NavigationStack {
        QuizView(quiz: DummyData.quizzes[0], lesson: DummyData.lessons[0])
            .environmentObject(DataStore.shared)
    }
}
