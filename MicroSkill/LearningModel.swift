import Foundation

/// Rule-based personalization engine that analyzes user behavior
/// to predict optimal learning times and enhance adaptive paths
@MainActor
final class LearningModel {
    static let shared = LearningModel()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Optimal Time Prediction
    
    /// Analyzes lesson completion history and returns the optimal hour for notifications
    func predictOptimalLearningHour() -> Int {
        let calendar = Calendar.current
        let lessons = DataStore.shared.lessons.filter { $0.completionDate != nil }
        
        guard !lessons.isEmpty else {
            // Default to 9 AM if no history
            return 9
        }
        
        // Group completions by hour
        var hourCounts: [Int: Int] = [:]
        for lesson in lessons {
            guard let date = lesson.completionDate else { continue }
            let hour = calendar.component(.hour, from: date)
            hourCounts[hour, default: 0] += 1
        }
        
        // Find the hour with most completions
        let bestHour = hourCounts.max { $0.value < $1.value }?.key ?? 9
        
        // Store for insights
        defaults.set(bestHour, forKey: "predictedOptimalHour")
        
        return bestHour
    }
    
    /// Returns a human-readable description of the optimal learning time
    func optimalTimeDescription() -> String {
        let hour = predictOptimalLearningHour()
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: date)
    }
    
    /// Schedules a smart notification based on predicted optimal time
    func scheduleOptimalReminder() {
        let hour = predictOptimalLearningHour()
        NotificationManager.shared.scheduleSmartReminder(basedOn: hour)
    }
    
    // MARK: - Learning Pattern Analysis
    
    /// Analyzes consistency patterns (consecutive days active)
    func consistencyScore() -> Double {
        let dailyCounts = DataStore.shared.dailyCompletionCounts(forDays: 14)
        let activeDays = dailyCounts.filter { $0.count > 0 }.count
        return Double(activeDays) / 14.0
    }
    
    /// Returns the user's peak performance category
    func peakPerformanceCategory() -> String {
        let breakdown = DataStore.shared.categoryBreakdown()
        return breakdown.first?.category ?? "Tech"
    }
    
    /// Predicts the next category the user should focus on
    func recommendedNextCategory() -> String {
        let userGoal = UserDefaults.standard.string(forKey: "userGoal") ?? "Tech Skills"
        let completedCount = DataStore.shared.completedLessonsCount
        
        // Map goal to primary category
        let goalCategory: String
        switch userGoal {
        case "Tech Skills":
            goalCategory = "Tech"
        case "Productivity":
            goalCategory = "Productivity"
        case "General Knowledge":
            goalCategory = "General Knowledge"
        default:
            goalCategory = "Tech"
        }
        
        // If user has completed fewer than 2 lessons in goal category, prioritize it
        let goalCompleted = DataStore.shared.lessons.filter {
            $0.category == goalCategory && $0.isCompleted
        }.count
        
        if goalCompleted < 2 {
            return goalCategory
        }
        
        // Otherwise, recommend based on weakest area or variety
        let categories = ["Tech", "Productivity", "General Knowledge"]
        let categoryCounts = categories.map { cat in
            (category: cat, count: DataStore.shared.lessons.filter {
                $0.category == cat && $0.isCompleted
            }.count)
        }
        
        return categoryCounts.min { $0.count < $1.count }?.category ?? goalCategory
    }
    
    // MARK: - Difficulty Progression
    
    /// Determines if user is ready for advanced lessons
    func isReadyForAdvanced() -> Bool {
        let completedCount = DataStore.shared.completedLessonsCount
        let totalLessons = DataStore.shared.totalLessonsCount
        let accuracy = quizAccuracy()
        
        // Ready if completed > 50% and quiz accuracy > 70%
        return completedCount >= totalLessons / 2 && accuracy > 0.7
    }
    
    /// Calculates overall quiz accuracy
    func quizAccuracy() -> Double {
        // This is a simplified metric - in a full implementation,
        // we'd track quiz results per attempt
        let completed = DataStore.shared.completedLessonsCount
        let total = DataStore.shared.totalLessonsCount
        return total == 0 ? 0.0 : Double(completed) / Double(total)
    }
    
    /// Returns a personalized learning recommendation message
    func personalizedRecommendation() -> String {
        let consistency = consistencyScore()
        let streak = DataStore.shared.progress.streak
        
        if streak == 0 {
            return "Start your streak today! Even one lesson makes a difference."
        } else if streak < 3 {
            return "You're building momentum! Try to complete a lesson at \(optimalTimeDescription())."
        } else if consistency < 0.5 {
            return "Great streak! For better retention, try learning at \(optimalTimeDescription())."
        } else {
            return "Excellent consistency! You're mastering \(peakPerformanceCategory()). Keep it up!"
        }
    }
}

