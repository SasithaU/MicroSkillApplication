import SwiftUI

struct LessonListView: View {
    let category: String
    @EnvironmentObject var store: DataStore
    
    var filteredLessons: [Lesson] {
        store.lessons.filter { $0.category == category }
    }
    
    var body: some View {
        if filteredLessons.isEmpty {
            // Show empty state
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: 40)
                    
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Lessons Available")
                        .font(Theme.headline())
                        .foregroundColor(.primary)
                    
                    Text("There are no lessons in the \(category) category yet, or all lessons have been completed.")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Total lessons loaded: \(store.lessons.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer(minLength: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.padding)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(category)
        } else {
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    ForEach(filteredLessons) { lesson in
                        let unlocked = store.isLessonUnlocked(lesson)
                        
                        if unlocked {
                            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                lessonRow(lesson: lesson, unlocked: true)
                            }
                            .buttonStyle(.plain)
                        } else {
                            lessonRow(lesson: lesson, unlocked: false)
                        }
                    }
                    
                    if store.allLessonsCompleted(in: category) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Theme.accent)
                                Text("Category Mastery")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 8)
                            
                            Text("Congratulations! You've finished all lessons in \(category). Now, test your knowledge.")
                                .font(Theme.body())
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 12) {
                                ForEach(filteredLessons) { lesson in
                                    if let quiz = store.quizForLesson(lesson.id) {
                                        NavigationLink(destination: QuizView(quiz: quiz, lesson: lesson)) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(lesson.title)
                                                        .font(.subheadline.weight(.medium))
                                                    Text("Final Quiz")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                Image(systemName: "play.fill")
                                                    .font(.caption)
                                                    .foregroundColor(Theme.primary)
                                            }
                                            .padding()
                                            .background(Theme.primary.opacity(0.08))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Theme.primary.opacity(0.15), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Theme.accent.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                        .padding(.top, 16)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(category)
        }
    }
    
    private func lessonRow(lesson: Lesson, unlocked: Bool) -> some View {
        HStack(spacing: 12) {
            IconTile(
                systemName: lesson.isCompleted ? "checkmark.circle.fill" : unlocked ? "book.fill" : "lock.fill",
                color: lesson.isCompleted ? Theme.success : unlocked ? Theme.primary : .secondary
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(unlocked ? .primary : .secondary)
                    
                    // Difficulty Badge
                    Text(lesson.difficulty.capitalized)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(difficultyColor(lesson.difficulty))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(difficultyColor(lesson.difficulty).opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(lesson.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            
            Image(systemName: unlocked ? "chevron.right" : "lock.fill")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .cardStyle()
        .opacity(unlocked ? 1.0 : 0.6)
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
        LessonListView(category: "Tech")
            .environmentObject(DataStore.shared)
    }
}
