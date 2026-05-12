import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    var categoryLimit: String? = nil
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showQuiz = false
    
    var currentLesson: Lesson? {
        store.lessons.first(where: { $0.id == lesson.id })
    }
    
    private var effectiveLesson: Lesson {
        currentLesson ?? lesson
    }
    
    var quizzes: [Quiz] {
        store.quizzesForLesson(effectiveLesson.id)
    }
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header Image/Icon Section
                    ZStack {
                        Circle()
                            .fill(Theme.heroGradient.opacity(0.1))
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                        
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.heroGradient)
                            .premiumShadow()
                    }
                    .padding(.top, 20)
                    
                    // Badges
                    HStack(spacing: 12) {
                        Text(effectiveLesson.category.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.primary.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(effectiveLesson.difficulty.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(difficultyColor(effectiveLesson.difficulty))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(difficultyColor(effectiveLesson.difficulty).opacity(0.1))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button {
                            store.toggleSaveLesson(effectiveLesson)
                        } label: {
                            Image(systemName: effectiveLesson.isSaved ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundColor(effectiveLesson.isSaved ? Theme.primary : .secondary)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(effectiveLesson.isSaved ? "Remove from saved" : "Save lesson")
                        .accessibilityHint("Double tap to toggle bookmark status")
                    }
                    
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(effectiveLesson.title)
                            .font(Theme.title())
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        if effectiveLesson.isCompleted {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Mastery: \(Int(effectiveLesson.masteryScore * 100))%")
                            }
                            .font(Theme.caption())
                            .foregroundStyle(Theme.success)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        Text(effectiveLesson.content)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.primary.opacity(0.85))
                            .lineSpacing(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .accessibilityLabel("Lesson content: \(effectiveLesson.content)")
                    
                    // Actions
                    VStack(spacing: 16) {
                        if !effectiveLesson.isCompleted {
                            Button {
                                store.markLessonCompleted(effectiveLesson)
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Mark as Completed")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            if store.allLessonsCompleted(in: effectiveLesson.category) && !quizzes.isEmpty {
                                Button {
                                    showQuiz = true
                                } label: {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("Start Category Quiz")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                            
                            if let next = store.nextLesson(after: effectiveLesson, inCategory: categoryLimit) {
                                NavigationLink(destination: LessonDetailView(lesson: next, categoryLimit: categoryLimit)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("NEXT LESSON")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.secondary)
                                            Text(next.title)
                                                .font(Theme.headline())
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(Theme.primary)
                                    }
                                    .padding()
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showQuiz) {
            if !quizzes.isEmpty {
                QuizView(quizzes: quizzes, lesson: effectiveLesson)
            }
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "beginner": return Theme.success
        case "intermediate": return Theme.primary
        case "advanced": return Theme.secondaryAccent
        default: return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        LessonDetailView(lesson: DummyData.lessons[0])
            .environmentObject(DataStore.shared)
    }
}
