import SwiftUI

struct LessonListView: View {
    let category: String
    @EnvironmentObject var store: DataStore
    
    var filteredLessons: [Lesson] {
        store.lessons.filter { $0.category == category }
    }
    
    private func isNewLesson(_ lesson: Lesson) -> Bool {
        let categoryLessons = filteredLessons.sorted { $0.order < $1.order }
        return categoryLessons.prefix(3).contains { $0.id == lesson.id }
    }
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            if filteredLessons.isEmpty {
                emptyStateView
            } else {
                lessonsView
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.primary.opacity(0.4))
            }
            
            VStack(spacing: 8) {
                Text("No Lessons Found")
                    .font(Theme.title())
                Text("We're currently curating lessons for \(category). Check back soon!")
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var lessonsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(category)
                        .font(Theme.largeTitle())
                    Text("\(filteredLessons.count) Lessons Available")
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    ForEach(filteredLessons) { lesson in
                        let unlocked = store.isLessonUnlocked(lesson)
                        
                        if unlocked {
                            NavigationLink(destination: LessonDetailView(lesson: lesson, categoryLimit: category)) {
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
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, Theme.padding)
        }
    }
    
    private func categoryMasterySection(quizzes: [CategoryMasteryQuiz]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.accent)
                    .font(.title3)
                Text("Mastery Challenges")
                    .font(Theme.headline())
            }
            
            VStack(spacing: 12) {
                ForEach(Array(quizzes.prefix(3).enumerated()), id: \.element.id) { index, quiz in
                    NavigationLink(destination: SimpleCategoryQuizView(quiz: quiz, category: category)) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Theme.accent.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.accent)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mastery Quiz")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Text("Earn points & mastery")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Theme.accent)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.accent.opacity(0.1), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .background(Theme.accent.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
    
    @ViewBuilder
    private func lessonRow(lesson: Lesson, unlocked: Bool) -> some View {
        let isNew = isNewLesson(lesson)
        
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(lesson.isCompleted ? Theme.success.opacity(0.1) : 
                          unlocked ? Theme.primary.opacity(0.1) : Color.secondary.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: lesson.isCompleted ? "checkmark" : unlocked ? "book.fill" : "lock.fill")
                    .foregroundStyle(lesson.isCompleted ? Theme.success : 
                                   unlocked ? Theme.primary : .secondary)
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(lesson.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(unlocked ? .primary : .secondary)
                    
                    if isNew && unlocked {
                        Text("NEW")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.accent)
                            .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 12) {
                    Label(lesson.difficulty.capitalized, systemImage: "gauge.with.dots.needle.33percent")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(difficultyColor(lesson.difficulty))
                    
                    if unlocked {
                        Text("Ready to start")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if unlocked {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(16)
        .glassCardStyle()
        .opacity(unlocked ? 1.0 : 0.6)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "beginner": return Theme.success
        case "intermediate": return Theme.accent
        case "advanced": return Theme.secondaryAccent
        default: return .secondary
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
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category)
                            .font(Theme.caption())
                            .foregroundColor(Theme.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.accent.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(quiz.question)
                            .font(Theme.title())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(quiz.options.enumerated()), id: \.offset) { index, option in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    selectedAnswerIndex = index
                                    isCorrect = index == quiz.correctAnswerIndex
                                    showResult = true
                                    store.markCategoryMasteryQuizUsed(quiz)
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(showResult && index == quiz.correctAnswerIndex ? Theme.success.opacity(0.1) :
                                                  showResult && index == selectedAnswerIndex ? Color.red.opacity(0.1) :
                                                  Color.primary.opacity(0.05))
                                            .frame(width: 40, height: 40)
                                        Text("\(String(Character(UnicodeScalar(65 + index)!)))")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(showResult && index == quiz.correctAnswerIndex ? Theme.success :
                                                           showResult && index == selectedAnswerIndex ? .red : .secondary)
                                    }
                                    
                                    Text(option)
                                        .font(Theme.body())
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    if showResult {
                                        Image(systemName: index == quiz.correctAnswerIndex ? "checkmark.circle.fill" : 
                                                       (index == selectedAnswerIndex ? "xmark.circle.fill" : ""))
                                            .foregroundStyle(index == quiz.correctAnswerIndex ? Theme.success : .red)
                                            .font(.title3)
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(showResult && index == quiz.correctAnswerIndex ? Theme.success :
                                                showResult && index == selectedAnswerIndex ? Color.red :
                                                Color.white.opacity(0.2), lineWidth: 1.5)
                                )
                                .premiumShadow()
                            }
                            .buttonStyle(.plain)
                            .disabled(showResult)
                        }
                    }
                    
                    if showResult {
                        VStack(spacing: 20) {
                            HStack(spacing: 12) {
                                Image(systemName: isCorrect ? "trophy.fill" : "lightbulb.fill")
                                    .font(.title2)
                                    .foregroundStyle(isCorrect ? .yellow : Theme.accent)
                                
                                Text(isCorrect ? "Mastery Achieved!" : "Keep Learning")
                                    .font(Theme.headline())
                            }
                            
                            if !isCorrect {
                                Text("The correct insight: \(quiz.options[quiz.correctAnswerIndex])")
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button { dismiss() } label: {
                                Text("Continue Learning")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(24)
                        .glassCardStyle()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LessonListView(category: "Tech")
            .environmentObject(DataStore.shared)
    }
}
