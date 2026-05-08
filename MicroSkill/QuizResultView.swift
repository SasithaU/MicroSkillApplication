import SwiftUI

struct QuizResultView: View {
    let isCorrect: Bool
    let lesson: Lesson
    let correctAnswer: String
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var didMarkComplete = false
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Animated Icon
                ZStack {
                    Circle()
                        .fill(isCorrect ? Theme.success.opacity(0.1) : Color.red.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 84))
                        .foregroundStyle(isCorrect ? Theme.success : Color.red)
                        .symbolEffect(.bounce, options: .repeat(1), value: isCorrect)
                        .premiumShadow()
                }
                
                // Result Text
                VStack(spacing: 12) {
                    Text(isCorrect ? "Brilliant Work!" : "Not Quite Yet")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if isCorrect {
                        Text("You've mastered this micro-skill. Ready to take on more?")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    } else {
                        VStack(spacing: 16) {
                            Text("Learning is a journey. Here's the correct path:")
                                .font(Theme.body())
                                .foregroundColor(.secondary)
                            
                            Text(correctAnswer)
                                .font(Theme.headline())
                                .foregroundStyle(Theme.primary)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.primary.opacity(0.2), lineWidth: 1))
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // Actions
                VStack(spacing: 16) {
                    if isCorrect {
                        if let next = store.nextLesson(after: lesson) {
                            NavigationLink(destination: LessonDetailView(lesson: next)) {
                                HStack {
                                    Text("Next Lesson")
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            Button { dismiss() } label: {
                                Text("Back to Dashboard")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    } else {
                        Button { dismiss() } label: {
                            Text("Review & Try Again")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
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
