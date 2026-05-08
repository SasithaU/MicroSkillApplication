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
    private let practiceBatchSize = 3
    private let practiceBatchIndexKey = "practiceBatchIndex"
    private let practiceLessonTemplates: [(title: String, content: String, category: String, difficulty: String, quizQuestion: String, quizOptions: [String], quizCorrectIndex: Int)] = [
        ("SwiftUI State Deep Dive", "Use @State for local changes, @Binding for shared edits, and @ObservedObject for model-driven updates.", "Tech", "intermediate", "Which property wrapper is primarily for local view state?", ["@Binding", "@ObservedObject", "@State", "@EnvironmentObject"], 2),
        ("Git Rebase Basics", "Rebase rewrites commit history to keep a clean linear timeline. Use it before merging feature branches.", "Tech", "intermediate", "What is the main purpose of git rebase in this lesson?", ["Delete old commits", "Rewrite history into a cleaner linear sequence", "Create a remote branch", "Stash local changes"], 1),
        ("API Error Handling", "Handle network errors by separating transport failures, server responses, and decoding issues.", "Tech", "advanced", "Which approach best matches robust API error handling?", ["Use one generic error for all failures", "Ignore decoding errors", "Separate transport, server, and decoding errors", "Retry forever without checks"], 2),
        ("Time Blocking", "Reserve focused blocks in your calendar and protect them from meetings for better deep work.", "Productivity", "beginner", "What is the key action in time blocking?", ["Work without a plan", "Reserve protected focus slots on your calendar", "Only do short tasks", "Always multitask"], 1),
        ("Task Batching", "Group similar tasks together to reduce context switching and improve execution speed.", "Productivity", "intermediate", "Task batching mainly helps by reducing what?", ["Deadlines", "Creativity", "Context switching", "Calendar events"], 2),
        ("Weekly Review Ritual", "Review wins, blockers, and priorities each week to align tasks with long-term goals.", "Productivity", "advanced", "Why do a weekly review ritual?", ["To add more meetings", "To align priorities with long-term goals", "To avoid planning", "To archive all tasks"], 1),
        ("Memory Anchoring", "Connect new information to familiar concepts to improve long-term retention.", "General Knowledge", "beginner", "Memory anchoring improves retention by doing what?", ["Repeating randomly", "Connecting new ideas to familiar concepts", "Studying only at night", "Skipping recall"], 1),
        ("Decision Fatigue", "Repeated choices reduce mental energy; simplify routine decisions to preserve focus.", "General Knowledge", "intermediate", "What does decision fatigue reduce over time?", ["Screen brightness", "Mental energy for choices", "Internet speed", "Working hours"], 1),
        ("Probability in Daily Life", "Use base rates and expected outcomes to make more rational everyday decisions.", "General Knowledge", "advanced", "Which concept supports more rational everyday decisions in this lesson?", ["Base rates and expected outcomes", "Pure intuition only", "Ignoring probabilities", "Random guessing"], 0)
    ]
    
    private init() {}
    
    // MARK: - Load
    
    func loadData() {
        guard !isLoaded else { return }
        isLoaded = true
        
        let context = stack.context
        
        // Check if data already exists and if model version matches
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        let existing = (try? context.count(for: request)) ?? 0
        let expectedCount = DummyData.lessons.count
        
        // Check if we need to reset because the store is empty,
        // has an unexpected lesson count, or the schema changed
        let needsReset = existing == 0 || existing != expectedCount || !storeHasDifficultyField()
        
        if needsReset {
            resetAllData()
        }
        
        if needsReset {
            // Seed with dummy data
            seedDummyData(context: context)
            stack.save()
        }
        
        fetchAll()
        updateProgress()
        refreshWidget()
        
        // Verify data loaded
        print("[DataStore] Loaded \(lessons.count) lessons, \(quizzes.count) quizzes")
    }
    
    private func storeHasDifficultyField() -> Bool {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        request.fetchLimit = 1
        do {
            if let entity = try stack.context.fetch(request).first {
                // Try to access difficulty - if it doesn't exist, this will fail silently in Core Data
                _ = entity.value(forKey: "difficulty")
                return true
            }
        } catch {
            return false
        }
        return false
    }
    
    private func resetAllData() {
        let entities = ["LessonEntity", "QuizEntity", "ProgressEntity"]
        for entityName in entities {
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? stack.context.execute(deleteRequest)
        }
        stack.save()
    }
    
    private func seedDummyData(context: NSManagedObjectContext) {
        // Seed dummy lessons with some having completion dates for chart demo
        let calendar = Calendar.current
        let now = Date()
        
        print("[DataStore] Seeding \(DummyData.lessons.count) lessons and \(DummyData.quizzes.count) quizzes")
        
        for (index, lesson) in DummyData.lessons.enumerated() {
            let entity = LessonEntity(context: context)
            entity.id = lesson.id
            entity.title = lesson.title
            entity.content = lesson.content
            entity.category = lesson.category
            entity.order = Int32(lesson.order)
            entity.difficulty = lesson.difficulty
            
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
        
        print("[DataStore] Seeding complete")
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
                        isSaved: $0.isSaved,
                        difficulty: $0.difficulty
                    )
            }
            print("[DataStore] Fetched \(lessons.count) lessons")
        } catch {
            print("[DataStore] Fetch lessons error: \(error)")
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
    
    func firstIncompleteLesson(inCategory category: String) -> Lesson? {
        lessons.first { !$0.isCompleted && $0.category == category }
    }
    
    func allLessonsCompleted(in category: String) -> Bool {
        let categoryLessons = lessons.filter { $0.category == category }
        guard !categoryLessons.isEmpty else { return false }
        return categoryLessons.allSatisfy(\.isCompleted)
    }
    
    func isLessonUnlocked(_ lesson: Lesson) -> Bool {
        let sorted = lessons.sorted(by: { $0.order < $1.order })

        // First lesson is always unlocked
        if let first = sorted.first, first.id == lesson.id {
            return true
        }

        // Unlock if the immediately previous lesson (by order) is completed
        guard let currentIndex = sorted.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        guard currentIndex > 0 else { return false }

        return sorted[currentIndex - 1].isCompleted
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
        var completed = lessons.filter(\.isCompleted).count

        if appendPracticeBatchIfNeeded(completedCount: completed) {
            fetchLessons()
            fetchQuizzes()
            completed = lessons.filter(\.isCompleted).count
        }

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

    private func appendPracticeBatchIfNeeded(completedCount: Int) -> Bool {
        guard !lessons.isEmpty, completedCount == lessons.count else {
            return false
        }

        let startBatchIndex = UserDefaults.standard.integer(forKey: practiceBatchIndexKey)
        let templateCount = practiceLessonTemplates.count
        guard templateCount > 0 else { return false }

        let maxOrder = lessons.map(\.order).max() ?? 0
        let startTemplate = (startBatchIndex * practiceBatchSize) % templateCount

        for offset in 0..<practiceBatchSize {
            let template = practiceLessonTemplates[(startTemplate + offset) % templateCount]
            let lessonId = UUID()

            let entity = LessonEntity(context: stack.context)
            entity.id = lessonId
            entity.title = template.title
            entity.content = template.content
            entity.category = template.category
            entity.isCompleted = false
            entity.order = Int32(maxOrder + offset + 1)
            entity.isSaved = false
            entity.difficulty = template.difficulty
            entity.completionDate = nil

            let quizEntity = QuizEntity(context: stack.context)
            quizEntity.id = UUID()
            quizEntity.lessonId = lessonId
            quizEntity.question = template.quizQuestion
            quizEntity.options = template.quizOptions
            quizEntity.correctAnswerIndex = Int32(template.quizCorrectIndex)
        }

        UserDefaults.standard.set(startBatchIndex + 1, forKey: practiceBatchIndexKey)
        stack.save()
        print("[DataStore] Added \(practiceBatchSize) new practice lessons.")
        return true
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

