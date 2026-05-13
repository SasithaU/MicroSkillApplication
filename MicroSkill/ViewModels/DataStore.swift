import Foundation
import CoreData
import SwiftUI
import WidgetKit

@MainActor
final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    private let groupSuiteName = "group.com.microskill.app"
    private var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: groupSuiteName) ?? UserDefaults.standard
    }
    
    @Published var lessons: [Lesson] = []
    @Published var quizzes: [Quiz] = []
    @Published var categoryMasteryQuizzes: [CategoryMasteryQuiz] = []
    @Published var activeSubject: String?
    @Published var progress: UserProgress = UserProgress() {
        didSet {
            if let encoded = try? JSONEncoder().encode(progress) {
                sharedDefaults.set(encoded, forKey: "user_progress_profile")
            }
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var geminiApiKey: String = "" {
        didSet {
            sharedDefaults.set(geminiApiKey, forKey: "gemini_api_key")
        }
    }
    @Published var isDataInitialized: Bool = false
    
    private let stack = CoreDataStack.shared
    private var isLoaded = false
    private let practiceBatchSize = 3
    private let practiceBatchIndexKey = "practiceBatchIndex"
    private let maxCategoryMasteryQuizzes = 10
    private let quizRenewalIntervalDays = 7 // Renew quizzes every week
    private let categoryMasteryQuizTemplates: [(category: String, question: String, options: [String], correctIndex: Int)] = [
        ("Tech", "What is the primary purpose of SwiftUI's @State property wrapper?", ["Managing app-wide state", "Managing local view state", "Handling network requests", "Storing user preferences"], 1),
        ("Tech", "Which Git command helps maintain a clean linear commit history?", ["git merge", "git rebase", "git stash", "git cherry-pick"], 1),
        ("Tech", "What's the best approach for robust API error handling?", ["Ignore all errors", "Use generic error messages", "Separate transport, server, and decoding errors", "Retry indefinitely"], 2),
        ("Productivity", "What is the key principle of time blocking?", ["Working without breaks", "Reserving protected focus slots on calendar", "Multitasking constantly", "Only doing urgent tasks"], 1),
        ("Productivity", "How does task batching primarily improve productivity?", ["By increasing deadlines", "By reducing context switching", "By adding more meetings", "By working longer hours"], 1),
        ("Productivity", "What's the main benefit of a weekly review ritual?", ["Adding more meetings", "Aligning priorities with long-term goals", "Avoiding all planning", "Archiving completed tasks"], 1),
        ("General Knowledge", "Memory anchoring improves retention by connecting new information to what?", ["Random facts", "Familiar concepts", "Unrelated topics", "Visual images only"], 1),
        ("General Knowledge", "What does decision fatigue primarily reduce?", ["Screen brightness", "Mental energy for choices", "Internet speed", "Working hours"], 1),
        ("General Knowledge", "Which concept supports more rational everyday decisions?", ["Pure intuition", "Base rates and expected outcomes", "Random guessing", "Ignoring probabilities"], 1)
    ]
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
    
    private init() {
        // 1. Check if it's ALREADY ready (to avoid missing the notification)
        if stack.isReady {
            print("[DataStore] Core Data was already ready in init. Loading...")
            loadData()
        }
        
        // 2. Also listen for the notification as a fallback
        NotificationCenter.default.addObserver(forName: NSNotification.Name("CoreDataStackReady"), object: nil, queue: .main) { [weak self] _ in
            print("[DataStore] Core Data notified as ready. Loading...")
            Task { @MainActor in
                self?.loadData()
            }
        }
    }
    
    // MARK: - Subject Management
    
    private func getInternalCategory(for subject: String) -> String {
        return subject // Always use the exact subject string for consistency
    }
    
    func setActiveSubject(_ subject: String) {
        isLoading = true
        activeSubject = subject
        sharedDefaults.set(subject, forKey: "activeSubject")
        
        let internalCategory = getInternalCategory(for: subject)
        errorMessage = nil
        clearLessons(for: internalCategory)
        
        Task {
            do {
                let curriculum = try await GeminiService.shared.generateCurriculum(for: subject, previouslyCovered: [])
                self.saveGeminiCurriculum(curriculum)
                self.isLoading = false
                self.fetchAll()
            } catch {
                self.errorMessage = "AI Error: \(error.localizedDescription)"
                self.isLoading = false
                self.fetchAll()
            }
        }
    }
    
    func generateMoreLessons() {
        guard let subject = activeSubject else { return }
        isLoading = true
        errorMessage = nil
        
        let previouslyCovered = lessons.map { $0.title }
        
        Task {
            do {
                let curriculum = try await GeminiService.shared.generateCurriculum(for: subject, previouslyCovered: previouslyCovered)
                self.saveGeminiCurriculum(curriculum)
                self.isLoading = false
                self.fetchAll()
            } catch {
                self.errorMessage = "AI Error: \(error.localizedDescription)"
                self.isLoading = false
                self.fetchAll()
            }
        }
    }
    
    private func clearLessons(for category: String) {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        request.predicate = NSPredicate(format: "category ==[c] %@", category)
        
        do {
            let results = try stack.context.fetch(request)
            for object in results {
                stack.context.delete(object)
            }
            stack.save()
            print("[DataStore] Cleared \(results.count) old lessons for category: \(category)")
        } catch {
            print("Clear lessons error: \(error)")
        }
    }
    
    private func saveGeminiCurriculum(_ curriculum: GeminiCurriculum) {
        let internalCategory = activeSubject ?? curriculum.subject
        
        // Get existing count for this category to maintain order
        let fetchRequest: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        fetchRequest.predicate = NSPredicate(format: "category ==[c] %@", internalCategory)
        let existingCount = (try? stack.context.count(for: fetchRequest)) ?? 0
        
        for (index, gLesson) in curriculum.lessons.enumerated() {
            let entity = LessonEntity(context: stack.context)
            entity.id = UUID()
            entity.title = gLesson.title
            entity.content = gLesson.content
            entity.category = internalCategory
            entity.order = Int32(existingCount + index + 1)
            entity.difficulty = gLesson.difficulty
            entity.isCompleted = false
            
            if entity.entity.attributesByName.keys.contains("masteryScore") {
                entity.setValue(0.0, forKey: "masteryScore")
            }
            
            // Save Multiple Quizzes
            for gQuiz in gLesson.quizzes {
                let qEntity = QuizEntity(context: stack.context)
                qEntity.id = UUID()
                qEntity.lessonId = entity.id
                qEntity.question = gQuiz.question
                qEntity.options = gQuiz.options
                qEntity.correctAnswerIndex = Int32(gQuiz.correctAnswerIndex)
            }
        }
        stack.save()
        print("[DataStore] Saved \(curriculum.lessons.count) Gemini lessons with multiple quizzes for category: \(internalCategory)")
    }
    
    func finishCurrentSubject() {
        print("[DataStore] Finishing subject: \(activeSubject ?? "None")")
        if let subject = activeSubject {
            clearLessons(for: getInternalCategory(for: subject))
        }
        activeSubject = nil
        sharedDefaults.removeObject(forKey: "activeSubject")
        fetchAll()
    }
    
    // MARK: - Load
    
    func loadData() {
        guard !isLoaded else { return }
        
        // Load active subject from shared defaults
        self.activeSubject = sharedDefaults.string(forKey: "activeSubject")
        
        // Load profile FIRST to ensure fields are present before fetchProgress triggers didSet
        self.geminiApiKey = sharedDefaults.string(forKey: "gemini_api_key") ?? ""
        loadProfile()
        
        isLoaded = true
        isDataInitialized = true
        
        let context = stack.context
        
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        let totalExisting = (try? context.count(for: request)) ?? 0
        print("[DataStore] loadData: Total lessons in DB: \(totalExisting)")
        
        fetchAll()
        updateProgress()
        refreshWidget()
        
        // Generate category mastery quizzes if needed
        generateCategoryMasteryQuizzesIfNeeded()
        
        // Verify data loaded
        print("[DataStore] loadData finished. Lessons: \(lessons.count), Subject: \(activeSubject ?? "None")")
        
        // If we have a subject but NO lessons, trigger a generation automatically
        if let subject = activeSubject, lessons.isEmpty, !geminiApiKey.isEmpty {
            print("[DataStore] Lessons missing for active subject. Triggering generation...")
            setActiveSubject(subject)
        }
    }
    
    private func loadProfile() {
        if let data = sharedDefaults.data(forKey: "user_progress_profile"),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            // Merge with current progress (which comes from CoreData usually, but here we use it for profile)
            var current = progress
            current.userName = decoded.userName
            current.profileImageData = decoded.profileImageData
            self.progress = current
        }
    }
    
    func updateProfile(name: String, imageData: Data?) {
        var current = progress
        current.userName = name
        current.profileImageData = imageData
        self.progress = current
    }
    
    private func storeHasDifficultyField() -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: "LessonEntity", in: stack.context) else { return false }
        return entity.attributesByName.keys.contains("difficulty")
    }

    private func storeHasMasteryScoreField() -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: "LessonEntity", in: stack.context) else { return false }
        return entity.attributesByName.keys.contains("masteryScore")
    }
    
    func resetAllData() {
        let entities = ["LessonEntity", "QuizEntity", "ProgressEntity", "CategoryMasteryQuizEntity"]
        for entityName in entities {
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? stack.context.execute(deleteRequest)
        }
        stack.save()
        
        // Clear in-memory and persistent profile/progress
        self.progress = UserProgress()
        sharedDefaults.removeObject(forKey: "user_progress_profile")
        sharedDefaults.removeObject(forKey: "userName")
        sharedDefaults.removeObject(forKey: "activeSubject")
        
        // Reset state
        self.lessons = []
        self.quizzes = []
        self.categoryMasteryQuizzes = []
    }
    
    private func seedDummyData(context: NSManagedObjectContext) {
        print("[DataStore] Seeding \(DummyData.lessons.count) lessons and \(DummyData.quizzes.count) quizzes")
        
        for lesson in DummyData.lessons {
            let entity = LessonEntity(context: context)
            entity.id = lesson.id
            entity.title = lesson.title
            entity.content = lesson.content
            entity.category = lesson.category
            entity.order = Int32(lesson.order)
            entity.difficulty = lesson.difficulty
            
            // Defensively set masteryScore if the field exists
            if entity.entity.attributesByName.keys.contains("masteryScore") {
                entity.setValue(lesson.masteryScore, forKey: "masteryScore")
            }
            
            entity.isCompleted = false
            entity.completionDate = nil
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
        fetchCategoryMasteryQuizzes()
        fetchProgress()
    }
    
    private func fetchLessons() {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        
        // Filter by subject-matched internal category if we have an active subject
        if let subject = activeSubject {
            let internalCategory = getInternalCategory(for: subject)
            print("[DataStore] Fetching lessons for active subject: \(subject), mapped to category: \(internalCategory)")
            request.predicate = NSPredicate(format: "category ==[c] %@", internalCategory)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            let entities = try stack.context.fetch(request)
            lessons = entities.map { mapEntityToLesson($0) }
            print("[DataStore] fetchLessons: Fetched \(lessons.count) lessons for subject: \(activeSubject ?? "None")")
        } catch {
            print("[DataStore] Fetch lessons error: \(error)")
        }
    }
    
    private func mapEntityToLesson(_ entity: LessonEntity) -> Lesson {
        return Lesson(
            id: entity.id,
            title: entity.title,
            content: entity.content,
            category: entity.category,
            isCompleted: entity.isCompleted,
            order: Int(entity.order),
            completionDate: entity.completionDate,
            isSaved: entity.isSaved,
            difficulty: entity.difficulty,
            prerequisiteIds: [],
            masteryScore: entity.entity.attributesByName.keys.contains("masteryScore") ? (entity.value(forKey: "masteryScore") as? Double) ?? 0.0 : 0.0
        )
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
    
    private func fetchCategoryMasteryQuizzes() {
        let request: NSFetchRequest<CategoryMasteryQuizEntity> = NSFetchRequest(entityName: "CategoryMasteryQuizEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let entities = try stack.context.fetch(request)
            categoryMasteryQuizzes = entities.map {
                CategoryMasteryQuiz(
                    id: $0.id,
                    category: $0.category,
                    question: $0.question,
                    options: $0.options,
                    correctAnswerIndex: Int($0.correctAnswerIndex),
                    createdAt: $0.createdAt,
                    isUsed: $0.isUsed
                )
            }
            print("[DataStore] Fetched \(categoryMasteryQuizzes.count) category mastery quizzes")
        } catch {
            print("Fetch category mastery quizzes error: \(error)")
        }
    }
    
    private func fetchProgress() {
        let request: NSFetchRequest<ProgressEntity> = NSFetchRequest(entityName: "ProgressEntity")
        
        do {
            let entities = try stack.context.fetch(request)
            if let entity = entities.first {
                var current = progress
                current.completedLessons = Int(entity.completedLessons)
                current.streak = Int(entity.streak)
                current.totalPoints = Int(entity.completedLessons) * 100 + Int(entity.streak) * 50
                current.lastAccessedLessonId = entity.lastLessonId
                progress = current
            } else {
                let newEntity = ProgressEntity(context: stack.context)
                newEntity.completedLessons = 0
                newEntity.streak = 0
                stack.save()
            }
        } catch {
            print("Fetch progress error: \(error)")
        }
    }
    
    // MARK: - Queries
    
    func quizzesForLesson(_ lessonId: UUID) -> [Quiz] {
        quizzes.filter { $0.lessonId == lessonId }
    }
    
    func getCategoryMasteryQuizzes(for category: String) -> [CategoryMasteryQuiz] {
        return categoryMasteryQuizzes.filter { $0.category == category && !$0.isUsed }
    }
    
    func generateCategoryMasteryQuizzesIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if we need to renew quizzes (either too few or too old)
        let needsRenewal = categoryMasteryQuizzes.isEmpty || 
            categoryMasteryQuizzes.allSatisfy { 
                calendar.dateComponents([.day], from: $0.createdAt, to: now).day ?? 0 >= quizRenewalIntervalDays 
            }
        
        if needsRenewal {
            renewCategoryMasteryQuizzes()
        }
    }
    
    private func renewCategoryMasteryQuizzes() {
        // Clear old quizzes
        clearOldCategoryMasteryQuizzes()
        
        // Generate new quizzes
        let categories = ["Tech", "Productivity", "General Knowledge"]
        
        for category in categories {
            let categoryTemplates = categoryMasteryQuizTemplates.filter { $0.category == category }
            let quizzesPerCategory = min(maxCategoryMasteryQuizzes / categories.count, categoryTemplates.count)
            
            for i in 0..<quizzesPerCategory {
                let template = categoryTemplates[i]
                let entity = CategoryMasteryQuizEntity(context: stack.context)
                entity.id = UUID()
                entity.category = template.category
                entity.question = template.question
                entity.options = template.options
                entity.correctAnswerIndex = Int32(template.correctIndex)
                entity.createdAt = Date()
                entity.isUsed = false
            }
        }
        
        stack.save()
        fetchCategoryMasteryQuizzes()
        print("[DataStore] Generated \(categoryMasteryQuizzes.count) new category mastery quizzes")
    }
    
    private func clearOldCategoryMasteryQuizzes() {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CategoryMasteryQuizEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try stack.context.execute(deleteRequest)
            print("[DataStore] Cleared old category mastery quizzes")
        } catch {
            print("Clear category mastery quizzes error: \(error)")
        }
    }
    
    func markCategoryMasteryQuizUsed(_ quiz: CategoryMasteryQuiz) {
        let request: NSFetchRequest<CategoryMasteryQuizEntity> = NSFetchRequest(entityName: "CategoryMasteryQuizEntity")
        request.predicate = NSPredicate(format: "id == %@", quiz.id as CVarArg)
        
        do {
            if let entity = try stack.context.fetch(request).first {
                entity.isUsed = true
                stack.save()
                fetchCategoryMasteryQuizzes()
            }
        } catch {
            print("Mark category mastery quiz used error: \(error)")
        }
    }
    
    func nextLesson(after lesson: Lesson, inCategory category: String? = nil) -> Lesson? {
        let candidates = lessons.filter { $0.order > lesson.order && !$0.isCompleted && isLessonUnlocked($0) }
        
        if let category = category {
            return candidates.first { $0.category == category }
        } else {
            return candidates.first
        }
    }
    
    func firstIncompleteLesson() -> Lesson? {
        lessons.first { !$0.isCompleted }
    }
    
    func firstIncompleteLesson(inCategory category: String) -> Lesson? {
        lessons.filter { isLessonUnlocked($0) }
            .first { !$0.isCompleted && $0.category == category }
    }
    
    func allLessonsCompleted(in category: String) -> Bool {
        let categoryLessons = lessons.filter { $0.category == category }
        guard !categoryLessons.isEmpty else { return false }
        return categoryLessons.allSatisfy(\.isCompleted)
    }
    
    func isLessonUnlocked(_ lesson: Lesson) -> Bool {
        // Find the lesson in our curriculum to get its prerequisites
        guard let curriculumLesson = DummyData.lessons.first(where: { $0.id == lesson.id }) else {
            return true // Fallback for dynamic lessons
        }
        
        let prerequisites = curriculumLesson.prerequisiteIds
        if prerequisites.isEmpty { return true }
        
        // All prerequisites must be completed
        return prerequisites.allSatisfy { prereqId in
            lessons.first(where: { $0.id == prereqId })?.isCompleted ?? false
        }
    }

    
    // MARK: - Mutations
    
    func markLessonCompleted(_ lesson: Lesson, score: Double = 1.0) {
        let request: NSFetchRequest<LessonEntity> = NSFetchRequest(entityName: "LessonEntity")
        request.predicate = NSPredicate(format: "id == %@", lesson.id as CVarArg)
        
        do {
            if let entity = try stack.context.fetch(request).first {
                entity.isCompleted = true
                entity.completionDate = Date()
                
                // Update mastery score if field exists
                if entity.entity.attributesByName.keys.contains("masteryScore") {
                    entity.setValue(score, forKey: "masteryScore")
                }
                
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
        let defaults = sharedDefaults
        defaults.set(progress.streak, forKey: "widgetStreak")
        defaults.set(completedLessonsCount, forKey: "widgetCompletedLessons")
        defaults.set(totalLessonsCount, forKey: "widgetTotalLessons")
        defaults.set(firstIncompleteLesson()?.title ?? "All Done!", forKey: "widgetNextLessonTitle")
        WidgetCenter.shared.reloadTimelines(ofKind: "MicroSkillWidget")
    }
}

class GeminiService {
    static let shared = GeminiService()
    
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent"
    
    func generateCurriculum(for subject: String, previouslyCovered: [String]) async throws -> GeminiCurriculum {
        let apiKey = await DataStore.shared.geminiApiKey
        
        guard !apiKey.isEmpty else {
            throw NSError(domain: "GeminiService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Gemini API Key is missing. Please go to API Settings and provide a valid key."])
        }
        
        let maskedKey = apiKey.count > 8 ? "\(apiKey.prefix(4))...\(apiKey.suffix(4))" : "****"
        print("[GeminiService] Generating curriculum for \(subject) with key: \(maskedKey)")
        
        let contextString = previouslyCovered.isEmpty ? "" : "Previously covered topics: \(previouslyCovered.joined(separator: ", ")). DO NOT repeat these. Build upon them."
        
        let prompt = """
        Create a 4-lesson curriculum for the subject: "\(subject)".
        \(contextString)
        Return ONLY a JSON object in this format:
        {
          "subject": "\(subject)",
          "lessons": [
            {
              "title": "Lesson Title",
              "content": "Short, easy-to-read micro-lesson using standard markdown (use **bold** for key terms and '* ' for bullet points) and relevant emojis (approx 100-150 words). Focus on key takeaways and keep it simple.",
              "difficulty": "advanced",
              "quizzes": [
                {
                  "question": "A challenging question",
                  "options": ["A", "B", "C", "D"],
                  "correctAnswerIndex": 0
                },
                {
                  "question": "Another challenging question about this lesson",
                  "options": ["A", "B", "C", "D"],
                  "correctAnswerIndex": 1
                }
              ]
            }
          ]
        }
        Ensure lessons follow a logical progression (Beginner -> Intermediate -> Advanced), each lesson has AT LEAST 2 different quiz questions, and the tone is encouraging and very easy to digest.
        """
        
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw NSError(domain: "GeminiService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "response_mime_type": "application/json"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("[GeminiService] Response status: \(httpResponse.statusCode)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message = (errorJson?["error"] as? [String: Any])?["message"] as? String ?? "API Error"
            print("[GeminiService] Error: \(message)")
            throw NSError(domain: "GeminiService", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard var jsonString = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw NSError(domain: "GeminiService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Empty response from AI"])
        }
        
        if jsonString.contains("```json") {
            jsonString = jsonString.replacingOccurrences(of: "```json", with: "")
            jsonString = jsonString.replacingOccurrences(of: "```", with: "")
        } else if jsonString.contains("```") {
            jsonString = jsonString.replacingOccurrences(of: "```", with: "")
        }
        
        let cleanedData = jsonString.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8)!
        return try JSONDecoder().decode(GeminiCurriculum.self, from: cleanedData)
    }
}


