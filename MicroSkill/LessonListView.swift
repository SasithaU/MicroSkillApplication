import SwiftUI

struct LessonListView: View {
    let category: String
    @EnvironmentObject var store: DataStore
    
    var filteredLessons: [Lesson] {
        store.lessons.filter { $0.category == category }
    }
    
    private var emptyStateView: some View {
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
    }
    
    private var lessonsView: some View {
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
                
                let categoryQuizzes = store.getCategoryMasteryQuizzes(for: category)
                if !categoryQuizzes.isEmpty {
                    categoryMasterySection(quizzes: categoryQuizzes)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 8)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(category)
    }
    
    @ViewBuilder
    var body: some View {
        if filteredLessons.isEmpty {
            emptyStateView
        } else {
            lessonsView
        }
    }
    
    private func categoryMasterySection(quizzes: [CategoryMasteryQuiz]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.accent)
                Text("Category Mastery")
                    .font(Theme.headline())
                    .foregroundColor(.primary)
            }
            .padding(.top, 8)
            
            Text("Test your knowledge with these \(category) mastery quizzes. Available for a limited time!")
                .font(Theme.body())
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(Array(quizzes.prefix(5).enumerated()), id: \.element.id) { index, quiz in
                    NavigationLink(destination: SimpleCategoryQuizView(quiz: quiz, category: category)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(category) Quiz \(index + 1)")
                                    .font(.subheadline.weight(.medium))
                                Text("Challenge yourself")
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
        .padding()
        .background(Theme.accent.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .padding(.top, 16)
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

struct SimpleCategoryQuizView: View {
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
                            .font(Theme.title())
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
                            .buttonStyle(PrimaryButtonStyle())
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
        LessonListView(category: "Tech")
            .environmentObject(DataStore.shared)
    }
}
