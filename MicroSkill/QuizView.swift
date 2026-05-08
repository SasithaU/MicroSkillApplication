import SwiftUI

struct QuizView: View {
    private struct QuizResultPayload: Identifiable, Hashable {
        let id = UUID()
        let isCorrect: Bool
        let correctAnswer: String
    }

    let quiz: Quiz
    let lesson: Lesson
    @EnvironmentObject var store: DataStore
    @State private var selectedIndex: Int? = nil
    @State private var resultPayload: QuizResultPayload?
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Question")
                            .font(Theme.caption())
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.primary.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(quiz.question)
                            .font(Theme.title())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    // Options
                    VStack(spacing: 16) {
                        ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                        QuizOptionButton(
                                option: option,
                                index: index,
                                selectedIndex: selectedIndex,
                                showResult: resultPayload != nil,
                                correctIndex: quiz.correctAnswerIndex
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
                            quiz.options.indices.contains(quiz.correctAnswerIndex)
                        else { return }

                        resultPayload = QuizResultPayload(
                            isCorrect: selectedIndex == quiz.correctAnswerIndex,
                            correctAnswer: quiz.options[quiz.correctAnswerIndex]
                        )
                    } label: {
                        HStack {
                            Text("Check Answer")
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
        .id(quiz.id)
        .onAppear {
            selectedIndex = nil
            resultPayload = nil
        }
        .navigationDestination(item: $resultPayload) { payload in
            QuizResultView(
                isCorrect: payload.isCorrect,
                lesson: lesson,
                correctAnswer: payload.correctAnswer
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
        QuizView(quiz: DummyData.quizzes[0], lesson: DummyData.lessons[0])
            .environmentObject(DataStore.shared)
    }
}
