import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    private(set) var isReady = false
    
    private init() {
        // Programmatic model definition (no .xcdatamodeld file needed)
        let model = NSManagedObjectModel()
        
        // LessonEntity
        let lessonEntity = NSEntityDescription()
        lessonEntity.name = "LessonEntity"
        lessonEntity.managedObjectClassName = "LessonEntity"
        
        let lessonId = NSAttributeDescription()
        lessonId.name = "id"
        lessonId.attributeType = .UUIDAttributeType
        
        let lessonTitle = NSAttributeDescription()
        lessonTitle.name = "title"
        lessonTitle.attributeType = .stringAttributeType
        
        let lessonContent = NSAttributeDescription()
        lessonContent.name = "content"
        lessonContent.attributeType = .stringAttributeType
        
        let lessonCategory = NSAttributeDescription()
        lessonCategory.name = "category"
        lessonCategory.attributeType = .stringAttributeType
        
        let lessonIsCompleted = NSAttributeDescription()
        lessonIsCompleted.name = "isCompleted"
        lessonIsCompleted.attributeType = .booleanAttributeType
        lessonIsCompleted.defaultValue = false
        
        let lessonOrder = NSAttributeDescription()
        lessonOrder.name = "order"
        lessonOrder.attributeType = .integer32AttributeType
        
        let lessonCompletedDate = NSAttributeDescription()
        lessonCompletedDate.name = "completionDate"
        lessonCompletedDate.attributeType = .dateAttributeType
        lessonCompletedDate.isOptional = true
        
        let lessonIsSaved = NSAttributeDescription()
        lessonIsSaved.name = "isSaved"
        lessonIsSaved.attributeType = .booleanAttributeType
        lessonIsSaved.defaultValue = false
        
        let lessonDifficulty = NSAttributeDescription()
        lessonDifficulty.name = "difficulty"
        lessonDifficulty.attributeType = .stringAttributeType
        lessonDifficulty.defaultValue = "beginner"
        
        lessonEntity.properties = [lessonId, lessonTitle, lessonContent, lessonCategory, lessonIsCompleted, lessonOrder, lessonCompletedDate, lessonIsSaved, lessonDifficulty]
        
        // QuizEntity
        let quizEntity = NSEntityDescription()
        quizEntity.name = "QuizEntity"
        quizEntity.managedObjectClassName = "QuizEntity"
        
        let quizId = NSAttributeDescription()
        quizId.name = "id"
        quizId.attributeType = .UUIDAttributeType
        
        let quizLessonId = NSAttributeDescription()
        quizLessonId.name = "lessonId"
        quizLessonId.attributeType = .UUIDAttributeType
        
        let quizQuestion = NSAttributeDescription()
        quizQuestion.name = "question"
        quizQuestion.attributeType = .stringAttributeType
        
        let quizOptions = NSAttributeDescription()
        quizOptions.name = "options"
        quizOptions.attributeType = .transformableAttributeType
        quizOptions.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        
        let quizCorrectIndex = NSAttributeDescription()
        quizCorrectIndex.name = "correctAnswerIndex"
        quizCorrectIndex.attributeType = .integer32AttributeType
        
        quizEntity.properties = [quizId, quizLessonId, quizQuestion, quizOptions, quizCorrectIndex]
        
        // ProgressEntity
        let progressEntity = NSEntityDescription()
        progressEntity.name = "ProgressEntity"
        progressEntity.managedObjectClassName = "ProgressEntity"
        
        let progressCompleted = NSAttributeDescription()
        progressCompleted.name = "completedLessons"
        progressCompleted.attributeType = .integer32AttributeType
        progressCompleted.defaultValue = 0
        
        let progressStreak = NSAttributeDescription()
        progressStreak.name = "streak"
        progressStreak.attributeType = .integer32AttributeType
        progressStreak.defaultValue = 0
        
        let progressLastLesson = NSAttributeDescription()
        progressLastLesson.name = "lastLessonId"
        progressLastLesson.attributeType = .UUIDAttributeType
        progressLastLesson.isOptional = true
        
        progressEntity.properties = [progressCompleted, progressStreak, progressLastLesson]
        
        // CategoryMasteryQuizEntity
        let categoryMasteryQuizEntity = NSEntityDescription()
        categoryMasteryQuizEntity.name = "CategoryMasteryQuizEntity"
        categoryMasteryQuizEntity.managedObjectClassName = "CategoryMasteryQuizEntity"
        
        let categoryMasteryQuizId = NSAttributeDescription()
        categoryMasteryQuizId.name = "id"
        categoryMasteryQuizId.attributeType = .UUIDAttributeType
        
        let categoryMasteryQuizCategory = NSAttributeDescription()
        categoryMasteryQuizCategory.name = "category"
        categoryMasteryQuizCategory.attributeType = .stringAttributeType
        
        let categoryMasteryQuizQuestion = NSAttributeDescription()
        categoryMasteryQuizQuestion.name = "question"
        categoryMasteryQuizQuestion.attributeType = .stringAttributeType
        
        let categoryMasteryQuizOptions = NSAttributeDescription()
        categoryMasteryQuizOptions.name = "options"
        categoryMasteryQuizOptions.attributeType = .transformableAttributeType
        categoryMasteryQuizOptions.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        
        let categoryMasteryQuizCorrectIndex = NSAttributeDescription()
        categoryMasteryQuizCorrectIndex.name = "correctAnswerIndex"
        categoryMasteryQuizCorrectIndex.attributeType = .integer32AttributeType
        
        let categoryMasteryQuizCreatedAt = NSAttributeDescription()
        categoryMasteryQuizCreatedAt.name = "createdAt"
        categoryMasteryQuizCreatedAt.attributeType = .dateAttributeType
        
        let categoryMasteryQuizIsUsed = NSAttributeDescription()
        categoryMasteryQuizIsUsed.name = "isUsed"
        categoryMasteryQuizIsUsed.attributeType = .booleanAttributeType
        categoryMasteryQuizIsUsed.defaultValue = false
        
        categoryMasteryQuizEntity.properties = [categoryMasteryQuizId, categoryMasteryQuizCategory, categoryMasteryQuizQuestion, categoryMasteryQuizOptions, categoryMasteryQuizCorrectIndex, categoryMasteryQuizCreatedAt, categoryMasteryQuizIsUsed]
        
        model.entities = [lessonEntity, quizEntity, progressEntity, categoryMasteryQuizEntity]
        
        persistentContainer = NSPersistentContainer(name: "MicroSkill", managedObjectModel: model)
        
        let groupID = "group.com.microskill.app"
        let storeName = "MicroSkill.sqlite"
        
        // 1. Define Old and New URLs
        let oldStoreURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(storeName)
        
        let newStoreURL: URL
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
            newStoreURL = groupURL.appendingPathComponent(storeName)
        } else {
            print("[CoreDataStack] WARNING: App Group not available, falling back to Sandbox")
            newStoreURL = oldStoreURL
        }
        
        // 2. Perform Migration if needed
        if newStoreURL != oldStoreURL && !FileManager.default.fileExists(atPath: newStoreURL.path) {
            if FileManager.default.fileExists(atPath: oldStoreURL.path) {
                print("[CoreDataStack] Migrating database from sandbox to App Group...")
                do {
                    try FileManager.default.moveItem(at: oldStoreURL, to: newStoreURL)
                    // Also move -wal and -shm files if they exist
                    let walURL = oldStoreURL.appendingPathExtension("wal")
                    let shmURL = oldStoreURL.appendingPathExtension("shm")
                    if FileManager.default.fileExists(atPath: walURL.path) {
                        try? FileManager.default.moveItem(at: walURL, to: newStoreURL.appendingPathExtension("wal"))
                    }
                    if FileManager.default.fileExists(atPath: shmURL.path) {
                        try? FileManager.default.moveItem(at: shmURL, to: newStoreURL.appendingPathExtension("shm"))
                    }
                } catch {
                    print("[CoreDataStack] Migration Error: \(error)")
                }
            }
        }
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: newStoreURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let description = NSPersistentStoreDescription(url: newStoreURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        persistentContainer.persistentStoreDescriptions = [description]
        
        print("[CoreDataStack] Store URL: \(newStoreURL.path)")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("[CoreDataStack] CRITICAL ERROR: \(error)")
                fatalError("Core Data load error: \(error), \(error.userInfo)")
            }
            print("[CoreDataStack] Persistent store loaded successfully")
            self.isReady = true
            NotificationCenter.default.post(name: NSNotification.Name("CoreDataStackReady"), object: nil)
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("[CoreDataStack] Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("[CoreDataStack] Save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - NSManagedObject Subclasses

@objc(LessonEntity)
public class LessonEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var category: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var order: Int32
    @NSManaged public var completionDate: Date?
    @NSManaged public var isSaved: Bool
    @NSManaged public var difficulty: String
}

@objc(QuizEntity)
public class QuizEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var lessonId: UUID
    @NSManaged public var question: String
    @NSManaged public var options: [String]
    @NSManaged public var correctAnswerIndex: Int32
}

@objc(ProgressEntity)
public class ProgressEntity: NSManagedObject {
    @NSManaged public var completedLessons: Int32
    @NSManaged public var streak: Int32
    @NSManaged public var lastLessonId: UUID?
}

@objc(CategoryMasteryQuizEntity)
public class CategoryMasteryQuizEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var category: String
    @NSManaged public var question: String
    @NSManaged public var options: [String]
    @NSManaged public var correctAnswerIndex: Int32
    @NSManaged public var createdAt: Date
    @NSManaged public var isUsed: Bool
}
