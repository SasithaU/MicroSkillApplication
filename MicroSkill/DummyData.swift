import Foundation

struct DummyData {
    static let lessons: [Lesson] = [
        Lesson(title: "Intro to React", content: "React is a JS library for building UI components efficiently.", category: "Tech", order: 1, difficulty: "beginner"),
        Lesson(title: "SwiftUI Basics", content: "SwiftUI is a modern framework for building user interfaces across Apple platforms.", category: "Tech", order: 2, difficulty: "beginner"),
        Lesson(title: "Pomodoro Technique", content: "Work 25 mins, break 5 mins. Repeat to maintain focus and productivity.", category: "Productivity", order: 3, difficulty: "beginner"),
        Lesson(title: "Deep Work", content: "Focus without distraction on a cognitively demanding task.", category: "Productivity", order: 4, difficulty: "intermediate"),
        Lesson(title: "World Capitals", content: "Paris is the capital of France, Tokyo of Japan, and Nairobi of Kenya.", category: "General Knowledge", order: 5, difficulty: "beginner"),
        Lesson(title: "Photosynthesis", content: "Plants convert light energy into chemical energy through photosynthesis.", category: "General Knowledge", order: 6, difficulty: "intermediate"),
        Lesson(title: "Advanced Swift Concurrency", content: "Master async/await, actors, and structured concurrency in Swift.", category: "Tech", order: 7, difficulty: "advanced"),
        Lesson(title: "System Design Basics", content: "Learn the fundamentals of designing scalable distributed systems.", category: "Tech", order: 8, difficulty: "advanced"),
        Lesson(title: "Getting Things Done", content: "A comprehensive workflow for personal productivity and task management.", category: "Productivity", order: 9, difficulty: "advanced"),
        Lesson(title: "Quantum Mechanics Intro", content: "Understanding superposition, entanglement, and wave-particle duality.", category: "General Knowledge", order: 10, difficulty: "advanced")
    ]
    
    static let quizzes: [Quiz] = [
        Quiz(lessonId: lessons[0].id, question: "What is React primarily used for?", options: ["Database management", "Building UI", "Server hosting", "Email services"], correctAnswerIndex: 1),
        Quiz(lessonId: lessons[1].id, question: "Which company developed SwiftUI?", options: ["Google", "Microsoft", "Apple", "Amazon"], correctAnswerIndex: 2),
        Quiz(lessonId: lessons[2].id, question: "How long is a standard Pomodoro work session?", options: ["15 mins", "25 mins", "45 mins", "60 mins"], correctAnswerIndex: 1),
        Quiz(lessonId: lessons[3].id, question: "What does 'Deep Work' emphasize?", options: ["Multitasking", "Distraction-free focus", "Social networking", "Email processing"], correctAnswerIndex: 1),
        Quiz(lessonId: lessons[4].id, question: "What is the capital of Japan?", options: ["Beijing", "Seoul", "Tokyo", "Bangkok"], correctAnswerIndex: 2),
        Quiz(lessonId: lessons[5].id, question: "What do plants convert light energy into?", options: ["Heat", "Sound", "Chemical energy", "Electricity"], correctAnswerIndex: 2)
    ]
}

