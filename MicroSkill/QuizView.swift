import SwiftUI

struct QuizView: View {
    private struct QuizResultPayload: Identifiable, Hashable {
        let id = UUID()
        let isCorrect: Bool
        let correctAnswer: String
        let isFinalQuestion: Bool
    }

    let quizzes: [Quiz]
    let lesson: Lesson
    @EnvironmentObject var store: DataStore
    
    @State private var currentQuizIndex: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var resultPayload: QuizResultPayload?
    
    private var currentQuiz: Quiz {
        quizzes[currentQuizIndex]
    }
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Progress Bar
                    if quizzes.count > 1 {
                        HStack(spacing: 4) {
                            ForEach(0..<quizzes.count, id: \.self) { index in
                                Capsule()
                                    .fill(index <= currentQuizIndex ? Theme.primary : Color.white.opacity(0.2))
                                    .frame(height: 4)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Question \(currentQuizIndex + 1) of \(quizzes.count)")
                                .font(Theme.caption())
                                .foregroundColor(Theme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.primary.opacity(0.1))
                                .clipShape(Capsule())
                            
                            Spacer()
                        }
                        
                        Text(currentQuiz.question)
                            .font(Theme.title())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    
                    // Options
                    VStack(spacing: 16) {
                        ForEach(Array(currentQuiz.options.enumerated()), id: \.offset) { index, option in
                            QuizOptionButton(
                                option: option,
                                index: index,
                                selectedIndex: selectedIndex,
                                showResult: resultPayload != nil,
                                correctIndex: currentQuiz.correctAnswerIndex
                            ) {
                                if resultPayload == nil {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        selectedIndex = index
                                    }
                                }
                            }
                        }
                    }
                    
                    // Submit
                    Button {
                        guard
                            let selectedIndex,
                            currentQuiz.options.indices.contains(currentQuiz.correctAnswerIndex)
                        else { return }

                        let isCorrect = selectedIndex == currentQuiz.correctAnswerIndex
                        let isFinal = currentQuizIndex == quizzes.count - 1
                        
                        if isCorrect && !isFinal {
                            // Automatically move to next question if correct and not final
                            withAnimation {
                                resultPayload = QuizResultPayload(
                                    isCorrect: true,
                                    correctAnswer: currentQuiz.options[currentQuiz.correctAnswerIndex],
                                    isFinalQuestion: false
                                )
                            }
                        } else {
                            // Show result view (for wrong answer or final question)
                            resultPayload = QuizResultPayload(
                                isCorrect: isCorrect,
                                correctAnswer: currentQuiz.options[currentQuiz.correctAnswerIndex],
                                isFinalQuestion: isFinal
                            )
                        }
                    } label: {
                        HStack {
                            Text(currentQuizIndex == quizzes.count - 1 ? "Check Final Answer" : "Check Answer")
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedIndex == nil)
                    .opacity(selectedIndex == nil ? 0.6 : 1.0)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .id(currentQuiz.id)
        .onAppear {
            selectedIndex = nil
            resultPayload = nil
        }
        .navigationDestination(item: $resultPayload) { payload in
            if payload.isCorrect && !payload.isFinalQuestion {
                // Temporary view to handle transition to next question
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.success)
                    Text("Correct!")
                        .font(Theme.title())
                    Text("Ready for the next one?")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                    
                    Button("Next Question") {
                        currentQuizIndex += 1
                        selectedIndex = nil
                        resultPayload = nil
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(PremiumBackground())
            } else {
                QuizResultView(
                    isCorrect: payload.isCorrect,
                    lesson: lesson,
                    correctAnswer: payload.correctAnswer
                )
            }
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
                              Color.primary.opacity(0.05))
                        .frame(width: 40, height: 40)
                    
                    Text("\(String(Character(UnicodeScalar(65 + index)!)))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(state == .correct ? Theme.success :
                                        state == .wrong ? .red :
                                        state == .selected ? Theme.primary : .secondary)
                }
                
                Text(option)
                    .font(Theme.body())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if state == .selected || state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(state == .correct ? Theme.success : Theme.primary)
                        .font(.title3)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.red)
                        .font(.title3)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(state == .selected ? Theme.primary :
                            state == .correct ? Theme.success :
                            state == .wrong ? Color.red :
                            Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .premiumShadow()
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }
}

#Preview {
    NavigationStack {
        QuizView(quizzes: DummyData.quizzes, lesson: DummyData.lessons[0])
            .environmentObject(DataStore.shared)
    }
}
