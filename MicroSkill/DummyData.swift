import Foundation

struct DummyData {
    // Static IDs to establish relationships
    static let reactId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let swiftUIId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let pomodoroId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let deepWorkId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let capitalsId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let photosynthesisId = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    static let concurrencyId = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!
    
    static let lessons: [Lesson] = [
        // Tech Track
        Lesson(id: reactId, title: "Intro to React", content: "React is a JS library for building UI components efficiently.", category: "Tech", order: 1, difficulty: "beginner", prerequisiteIds: []),
        Lesson(id: swiftUIId, title: "SwiftUI Basics", content: "SwiftUI is a modern framework for building user interfaces across Apple platforms.", category: "Tech", order: 2, difficulty: "beginner", prerequisiteIds: []),
        Lesson(id: concurrencyId, title: "Advanced Swift Concurrency", content: "Master async/await, actors, and structured concurrency in Swift.", category: "Tech", order: 7, difficulty: "advanced", prerequisiteIds: [swiftUIId]),
        Lesson(id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!, title: "System Design Basics", content: "Learn the fundamentals of designing scalable distributed systems.", category: "Tech", order: 8, difficulty: "advanced", prerequisiteIds: [concurrencyId]),
        
        // Productivity Track
        Lesson(id: pomodoroId, title: "Pomodoro Technique", content: "Work 25 mins, break 5 mins. Repeat to maintain focus and productivity.", category: "Productivity", order: 3, difficulty: "beginner", prerequisiteIds: []),
        Lesson(id: deepWorkId, title: "Deep Work", content: "Focus without distraction on a cognitively demanding task.", category: "Productivity", order: 4, difficulty: "intermediate", prerequisiteIds: [pomodoroId]),
        Lesson(id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!, title: "Getting Things Done", content: "A comprehensive workflow for personal productivity and task management.", category: "Productivity", order: 9, difficulty: "advanced", prerequisiteIds: [deepWorkId]),
        
        // Knowledge Track
        Lesson(id: capitalsId, title: "World Capitals", content: "Paris is the capital of France, Tokyo of Japan, and Nairobi of Kenya.", category: "General Knowledge", order: 5, difficulty: "beginner", prerequisiteIds: []),
        Lesson(id: photosynthesisId, title: "Photosynthesis", content: "Plants convert light energy into chemical energy through photosynthesis.", category: "General Knowledge", order: 6, difficulty: "intermediate", prerequisiteIds: []),
        Lesson(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, title: "Quantum Mechanics Intro", content: "Understanding superposition, entanglement, and wave-particle duality.", category: "General Knowledge", order: 10, difficulty: "advanced", prerequisiteIds: [photosynthesisId]),
        
        // Web Development Track
        Lesson(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!, title: "Intro to Next.js", content: "Next.js is a React framework for production with SSR, SSG, and API routes.", category: "Web Development", order: 1, difficulty: "beginner", prerequisiteIds: []),
        Lesson(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!, title: "App Router & Server Components", content: "Learn the power of Next.js 13+ App Router and Server Components.", category: "Web Development", order: 2, difficulty: "intermediate", prerequisiteIds: [UUID(uuidString: "00000000-0000-0000-0000-000000000011")!])
    ]
    
    static let quizzes: [Quiz] = [
        Quiz(lessonId: reactId, question: "What is React primarily used for?", options: ["Database management", "Building UI", "Server hosting", "Email services"], correctAnswerIndex: 1),
        Quiz(lessonId: swiftUIId, question: "Which company developed SwiftUI?", options: ["Google", "Microsoft", "Apple", "Amazon"], correctAnswerIndex: 2),
        Quiz(lessonId: pomodoroId, question: "How long is a standard Pomodoro work session?", options: ["15 mins", "25 mins", "45 mins", "60 mins"], correctAnswerIndex: 1),
        Quiz(lessonId: deepWorkId, question: "What does 'Deep Work' emphasize?", options: ["Multitasking", "Distraction-free focus", "Social networking", "Email processing"], correctAnswerIndex: 1),
        Quiz(lessonId: capitalsId, question: "What is the capital of Japan?", options: ["Beijing", "Seoul", "Tokyo", "Bangkok"], correctAnswerIndex: 2),
        Quiz(lessonId: photosynthesisId, question: "What do plants convert light energy into?", options: ["Heat", "Sound", "Chemical energy", "Electricity"], correctAnswerIndex: 2),
        Quiz(lessonId: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!, question: "What does SSR stand for in Next.js?", options: ["Static Site Rendering", "Server-Side Rendering", "Simple Script Runner", "Standard Socket Request"], correctAnswerIndex: 1)
    ]
}
