import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showQuiz = false
    
    var currentLesson: Lesson? {
        store.lessons.first(where: { $0.id == lesson.id })
    }
    
    var quiz: Quiz? {
        store.quizForLesson(lesson.id)
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing * 1.5) {
                    // Category Badge + Difficulty
                    HStack {
                        Text(lesson.category)
                            .font(Theme.caption())
                            .foregroundStyle(Theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.primary.opacity(0.12))
                            .cornerRadius(8)
                        
                        // Difficulty Badge
                        Text(lesson.difficulty.capitalized)
                            .font(Theme.caption())
                            .foregroundColor(difficultyColor(lesson.difficulty))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(difficultyColor(lesson.difficulty).opacity(0.12))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        // Bookmark button
                        Button {
                            if let current = currentLesson {
                                store.toggleSaveLesson(current)
                            }
                        } label: {
                            Image(systemName: (currentLesson?.isSaved ?? false) ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundColor((currentLesson?.isSaved ?? false) ? Theme.primary : .secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)
                        .accessibilityLabel((currentLesson?.isSaved ?? false) ? "Remove bookmark" : "Bookmark lesson")
                        
                        if lesson.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Completed")
                            }
                            .font(Theme.caption())
                            .foregroundStyle(Theme.success)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.success.opacity(0.12))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Adaptive Path Warning for Advanced Lessons
                    if lesson.difficulty == "advanced" && !LearningModel.shared.isReadyForAdvanced() {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Theme.accent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Advanced Lesson")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.accent)
                                    .textCase(.uppercase)
                                
                                Text("Complete more beginner lessons to unlock your full potential.")
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Theme.accent.opacity(0.08))
                        .cornerRadius(Theme.cardCornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .stroke(Theme.accent.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Title
                    Text(lesson.title)
                        .font(Theme.title())
                        .foregroundStyle(Theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Content Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lesson")
                            .font(Theme.headline())
                            .foregroundColor(.primary)
                        
                        Text(lesson.content)
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .cardStyle()
                    
                    // Action Buttons
                    if !lesson.isCompleted {
                        if quiz != nil {
                            Button {
                                showQuiz = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                    Text("Start Quiz")
                                        .font(Theme.headline())
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.heroGradient)
                                .foregroundColor(.white)
                                .cornerRadius(Theme.cardCornerRadius)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Start quiz for \(lesson.title)")
                        }
                        
                        Button {
                            store.markLessonCompleted(lesson)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Mark as Completed")
                                    .font(Theme.headline())
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.success.opacity(0.15))
                            .foregroundStyle(Theme.success)
                            .cornerRadius(Theme.cardCornerRadius)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Mark \(lesson.title) as completed")
                    } else {
                        // Next lesson navigation
                        if let next = store.nextLesson(after: lesson) {
                            NavigationLink(value: next) {
                                HStack(spacing: 10) {
                                    Text("Next: \(next.title)")
                                        .font(Theme.headline())
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.title3)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primary.opacity(0.1))
                                .foregroundStyle(Theme.primary)
                                .cornerRadius(Theme.cardCornerRadius)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Next lesson: \(next.title)")
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "star.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(Theme.heroGradient)
                                
                                Text("All lessons completed!")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .cardStyle()
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showQuiz) {
            if let quiz = quiz {
                QuizView(quiz: quiz, lesson: lesson)
            }
        }
        .navigationDestination(for: Lesson.self) { nextLesson in
            LessonDetailView(lesson: nextLesson)
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "beginner":
            return Theme.success
        case "intermediate":
            return Theme.accent
        case "advanced":
            return Color.red
        default:
            return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: DummyData.lessons[0])
            .environmentObject(DataStore.shared)
    }
}
