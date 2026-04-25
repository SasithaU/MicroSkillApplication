import Foundation

struct Lesson: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var content: String
    var category: String
    var isCompleted: Bool = false
    var order: Int
    var completionDate: Date?
    var isSaved: Bool = false
    var difficulty: String = "beginner" // beginner, intermediate, advanced
}

struct Quiz: Identifiable, Codable {
    var id = UUID()
    var lessonId: UUID
    var question: String
    var options: [String]
    var correctAnswerIndex: Int
}

struct UserProgress: Codable {
    var completedLessons: Int = 0
    var streak: Int = 0
    var lastAccessedLessonId: UUID?
}