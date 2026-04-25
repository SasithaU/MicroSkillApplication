import SwiftUI

struct LessonListView: View {
    let category: String
    @EnvironmentObject var store: DataStore
    
    var filteredLessons: [Lesson] {
        store.lessons.filter { $0.category == category }
    }
    
    var body: some View {
        List(filteredLessons) { lesson in
            let unlocked = store.isLessonUnlocked(lesson)
            
            if unlocked {
                NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                    lessonRow(lesson: lesson, unlocked: true)
                }
            } else {
                lessonRow(lesson: lesson, unlocked: false)
            }
        }
        .navigationTitle(category)
    }
    
    private func lessonRow(lesson: Lesson, unlocked: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundColor(unlocked ? .primary : .secondary)
                Text(lesson.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.success)
                    .font(.title3)
            } else if !unlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
        .opacity(unlocked ? 1.0 : 0.6)
    }
}

#Preview {
    NavigationStack {
        LessonListView(category: "Tech")
            .environmentObject(DataStore.shared)
    }
}
