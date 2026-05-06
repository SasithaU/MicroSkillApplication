import SwiftUI

struct QuizResultView: View {
    let isCorrect: Bool
    let lesson: Lesson
    let correctAnswer: String
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var didMarkComplete = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(isCorrect ? Theme.success : Color.red)
                .symbolEffect(.bounce, options: .repeat(1), value: isCorrect)
            
            // Title
            Text(isCorrect ? "Correct!" : "Not Quite")
                .font(Theme.largeTitle())
                .foregroundColor(.primary)
            
            // Subtitle
            if isCorrect {
                Text("Great job! You've completed this lesson.")
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 8) {
                    Text("The correct answer was:")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                    
                    Text(correctAnswer)
                        .font(Theme.headline())
                        .foregroundStyle(Theme.primary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                if isCorrect {
                    if let next = store.nextLesson(after: lesson) {
                        NavigationLink(destination: LessonDetailView(lesson: next)) {
                            HStack(spacing: 10) {
                                Text("Next Lesson")
                                    .font(Theme.headline())
                                Image(systemName: "arrow.right")
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.heroGradient)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.cardCornerRadius)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Next lesson: \(next.title)")
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 10) {
                                Text("Back to Home")
                                    .font(Theme.headline())
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.heroGradient)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.cardCornerRadius)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Back to home dashboard")
                    }
                } else {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Try Again")
                                .font(Theme.headline())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary.opacity(0.12))
                        .foregroundStyle(Theme.primary)
                        .cornerRadius(Theme.cardCornerRadius)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Try quiz again")
                }
            }
            .padding(.horizontal, Theme.padding)
        }
        .padding()
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if isCorrect && !didMarkComplete && !lesson.isCompleted {
                store.markLessonCompleted(lesson)
                didMarkComplete = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuizResultView(isCorrect: true, lesson: DummyData.lessons[0], correctAnswer: "Building UI")
            .environmentObject(DataStore.shared)
    }
}
