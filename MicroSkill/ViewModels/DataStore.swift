import Foundation
import CoreData
import SwiftUI
import WidgetKit

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
        updateProgress()
        refreshWidget()
    }
    
    private func seedDummyData(context: NSManagedObjectContext) {
        // Seed dummy lessons with some having completion dates for chart demo
        let calendar = Calendar.current
        let now = Date()
        
        for (index, lesson) in DummyData.lessons.enumerated() {
            let entity = LessonEntity(context: context)
            entity.id = lesson.id
            entity.title = lesson.title
            entity.content = lesson.content
            entity.category = lesson.category
            entity.order = Int32(lesson.order)
            
            // Mark first 3 lessons as completed with scattered dates
            if index < 3 {
                entity.isCompleted = true
                let daysAgo = [0, 1, 3][index]
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) {
                    entity.completionDate = calendar.date(bySettingHour: 9 + index, minute: 30, second: 0, of: date)
                }
            } else {
                entity.isCompleted = false
            }
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
                    order: Int($0.order),
                    completionDate: $0.completionDate,
                    isSaved: $0.isSaved
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
                newEntity.streak = 0
                stack.save()
                progress = UserProgress(streak: 0)
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
                entity.completionDate = Date()
                stack.save()
                fetchLessons()
                updateProgress()
            }
        } catch {
            print("Mark complete error: \(error)")
        }
    }
    
    // MARK: - Streak Calculation
    
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        let completedLessons = lessons.filter { $0.completionDate != nil }
        
        guard !completedLessons.isEmpty else { return 0 }
        
        // Get unique completion days (normalized to start of day)
        let completionDays = completedLessons.compactMap { $0.completionDate }
            .map { calendar.startOfDay(for: $0) }
        
        let uniqueDays = Array(Set(completionDays)).sorted(by: >)
        
        guard let mostRecentDay = uniqueDays.first else { return 0 }
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // If the most recent completion is not today or yesterday, streak is broken
        if mostRecentDay != today && mostRecentDay != yesterday {
            return 0
        }
        
        // Count consecutive days backwards from most recent
        var streak = 1
        var checkDay = mostRecentDay
        
        for day in uniqueDays.dropFirst() {
            let expectedPrevious = calendar.date(byAdding: .day, value: -1, to: checkDay)!
            if day == expectedPrevious {
                streak += 1
                checkDay = day
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func updateProgress() {
        let completed = lessons.filter(\.isCompleted).count
        let streak = calculateStreak()
        let request: NSFetchRequest<ProgressEntity> = NSFetchRequest(entityName: "ProgressEntity")
        
        do {
            if let entity = try stack.context.fetch(request).first {
                entity.completedLessons = Int32(completed)
                entity.streak = Int32(streak)
                stack.save()
                fetchProgress()
                refreshWidget()
            }
        } catch {
            print("Update progress error: \(error)")
        }
    }
    
    // MARK: - Saved Lessons
    
    func toggleSaveLesson(_ lesson: Lesson) {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        request.predicate = NSPredicate(format: "id == %@", lesson.id as CVarArg)
        
        do {
            if let entity = try stack.context.fetch(request).first {
                entity.isSaved.toggle()
                stack.save()
                fetchLessons()
            }
        } catch {
            print("Toggle save error: \(error)")
        }
    }
    
    var savedLessons: [Lesson] {
        lessons.filter(\.isSaved)
    }
    
    // MARK: - Analytics
    
    /// Returns daily completion counts for the last N days, ordered oldest to newest
    func dailyCompletionCounts(forDays days: Int = 7) -> [(date: Date, count: Int, weekday: String)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var result: [(date: Date, count: Int, weekday: String)] = []
        
        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            
            let count = lessons.filter {
                guard let completion = $0.completionDate else { return false }
                return completion >= date && completion < nextDate
            }.count
            
            let weekday = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            result.append((date: date, count: count, weekday: weekday))
        }
        
        return result
    }
    
    /// Best learning time as a human-readable string (e.g., "9:00 AM")
    func bestLearningTime() -> String {
        let calendar = Calendar.current
        let completedLessons = lessons.filter { $0.completionDate != nil }
        
        guard !completedLessons.isEmpty else { return "--" }
        
        // Group by hour of day
        var hourCounts: [Int: Int] = [:]
        for lesson in completedLessons {
            guard let date = lesson.completionDate else { continue }
            let hour = calendar.component(.hour, from: date)
            hourCounts[hour, default: 0] += 1
        }
        
        guard let bestHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return "--"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let referenceDate = calendar.date(bySettingHour: bestHour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: referenceDate)
    }
    
    /// Most active day of the week (e.g., "Monday")
    func mostActiveDay() -> String {
        let calendar = Calendar.current
        let completedLessons = lessons.filter { $0.completionDate != nil }
        
        guard !completedLessons.isEmpty else { return "--" }
        
        var dayCounts: [Int: Int] = [:]
        for lesson in completedLessons {
            guard let date = lesson.completionDate else { continue }
            let weekday = calendar.component(.weekday, from: date)
            dayCounts[weekday, default: 0] += 1
        }
        
        guard let bestDay = dayCounts.max(by: { $0.value < $1.value })?.key else {
            return "--"
        }
        
        return calendar.weekdaySymbols[bestDay - 1]
    }
    
    /// Estimated total study time in minutes (30–60 seconds per lesson)
    func totalStudyTimeMinutes() -> Int {
        let completed = lessons.filter(\.isCompleted).count
        return completed * 1 // Approx 1 min per lesson for tracking
    }
    
    /// Average lessons per day over the last 7 days
    func averageLessonsPerDay() -> Double {
        let daily = dailyCompletionCounts(forDays: 7)
        let total = daily.reduce(0) { $0 + $1.count }
        return Double(total) / 7.0
    }
    
    /// Total completed lessons count
    var completedLessonsCount: Int {
        lessons.filter(\.isCompleted).count
    }
    
    /// Total available lessons count
    var totalLessonsCount: Int {
        lessons.count
    }
    
    /// Category breakdown: [Category: Completed Count]
    func categoryBreakdown() -> [(category: String, count: Int)] {
        let categories = Array(Set(lessons.map(\.category)))
        return categories.map { cat in
            let count = lessons.filter { $0.category == cat && $0.isCompleted }.count
            return (category: cat, count: count)
        }.sorted { $0.count > $1.count }
    }
    
    // MARK: - Widget Data Sharing
    
    func refreshWidget() {
        let defaults = UserDefaults(suiteName: "group.com.microskill.app") ?? UserDefaults.standard
        defaults.set(progress.streak, forKey: "widgetStreak")
        defaults.set(completedLessonsCount, forKey: "widgetCompletedLessons")
        defaults.set(totalLessonsCount, forKey: "widgetTotalLessons")
        defaults.set(firstIncompleteLesson()?.title ?? "All Done!", forKey: "widgetNextLessonTitle")
        WidgetCenter.shared.reloadTimelines(ofKind: "MicroSkillWidget")
    }
}

