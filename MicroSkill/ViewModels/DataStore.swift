import Foundation
import CoreData
import SwiftUI

@MainActor
final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var lessons: [Lesson] = []
    @Published var quizzes: [Quiz] = []
    @Published var progress: UserProgress = UserProgress()
    
    private let stack = CoreDataStack.shared
    private var isLoaded = false
    
    private init() {}
    
    // MARK: - Load
    
    func loadData() {
        guard !isLoaded else { return }
        isLoaded = true
        
        let context = stack.context
        
        // Check if data already exists
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        let existing = (try? context.count(for: request)) ?? 0
        
        if existing == 0 {
            // Seed with dummy data
            seedDummyData(context: context)
        }
        
        fetchAll()
    }
    
    private func seedDummyData(context: NSManagedObjectContext) {
        for lesson in DummyData.lessons {
            let entity = LessonEntity(context: context)
            entity.id = lesson.id
            entity.title = lesson.title
            entity.content = lesson.content
            entity.category = lesson.category
            entity.isCompleted = lesson.isCompleted
            entity.order = Int32(lesson.order)
        }
        
        for quiz in DummyData.quizzes {
            let entity = QuizEntity(context: context)
            entity.id = quiz.id
            entity.lessonId = quiz.lessonId
            entity.question = quiz.question
            entity.options = quiz.options
            entity.correctAnswerIndex = Int32(quiz.correctAnswerIndex)
        }
        
        stack.save()
    }
    
    private func fetchAll() {
        fetchLessons()
        fetchQuizzes()
        fetchProgress()
    }
    
    private func fetchLessons() {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            let entities = try stack.context.fetch(request)
            lessons = entities.map {
                Lesson(
                    id: $0.id,
                    title: $0.title,
                    content: $0.content,
                    category: $0.category,
                    isCompleted: $0.isCompleted,
                    order: Int($0.order)
                )
            }
        } catch {
            print("Fetch lessons error: \(error)")
        }
    }
    
    private func fetchQuizzes() {
        let request: NSFetchRequest<QuizEntity> = NSFetchRequest(entityName: "QuizEntity")
        
        do {
            let entities = try stack.context.fetch(request)
            quizzes = entities.map {
                Quiz(
                    id: $0.id,
                    lessonId: $0.lessonId,
                    question: $0.question,
                    options: $0.options,
                    correctAnswerIndex: Int($0.correctAnswerIndex)
                )
            }
        } catch {
            print("Fetch quizzes error: \(error)")
        }
    }
    
    private func fetchProgress() {
        let request: NSFetchRequest<ProgressEntity> = NSFetchRequest(entityName: "ProgressEntity")
        
        do {
            let entities = try stack.context.fetch(request)
            if let entity = entities.first {
                progress = UserProgress(
                    completedLessons: Int(entity.completedLessons),
                    streak: Int(entity.streak),
                    lastAccessedLessonId: entity.lastLessonId
                )
            } else {
                let newEntity = ProgressEntity(context: stack.context)
                newEntity.completedLessons = 0
                newEntity.streak = 1
                stack.save()
                progress = UserProgress(streak: 1)
            }
        } catch {
            print("Fetch progress error: \(error)")
        }
    }
    
    // MARK: - Queries
    
    func quizForLesson(_ lessonId: UUID) -> Quiz? {
        quizzes.first { $0.lessonId == lessonId }
    }
    
    func nextLesson(after lesson: Lesson) -> Lesson? {
        lessons.first { $0.order > lesson.order && !$0.isCompleted }
    }
    
    func firstIncompleteLesson() -> Lesson? {
        lessons.first { !$0.isCompleted }
    }
    
    func isLessonUnlocked(_ lesson: Lesson) -> Bool {
        // First lesson is always unlocked
        if let first = lessons.first, first.id == lesson.id {
            return true
        }
        // A lesson is unlocked if the previous one is completed
        guard let currentIndex = lessons.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        let previousIndex = lessons.index(before: currentIndex)
        return lessons[previousIndex].isCompleted
    }
    
    // MARK: - Mutations
    
    func markLessonCompleted(_ lesson: Lesson) {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        request.predicate = NSPredicate(format: "id == %@", lesson.id as CVarArg)
        
        do {
            if let entity = try stack.context.fetch(request).first {
                entity.isCompleted = true
                stack.save()
                fetchLessons()
                updateProgress()
            }
        } catch {
            print("Mark complete error: \(error)")
        }
    }
    
    private func updateProgress() {
        let completed = lessons.filter(\.isCompleted).count
        let request: NSFetchRequest<ProgressEntity> = NSFetchRequest(entityName: "ProgressEntity")
        
        do {
            if let entity = try stack.context.fetch(request).first {
                entity.completedLessons = Int32(completed)
                stack.save()
                fetchProgress()
            }
        } catch {
            print("Update progress error: \(error)")
        }
    }
}
