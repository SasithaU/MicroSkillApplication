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
                    // Category Badge
                    HStack {
                        Text(lesson.category)
                            .font(Theme.caption())
                            .foregroundStyle(Theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.primary.opacity(0.12))
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
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: DummyData.lessons[0])
            .environmentObject(DataStore.shared)
    }
}
