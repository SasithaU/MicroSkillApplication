import SwiftUI

struct LessonListView: View {
    let category: String
    @EnvironmentObject var store: DataStore
    
    var filteredLessons: [Lesson] {
        store.lessons.filter { $0.category == category }
    }
    
    var body: some View {
        List(filteredLessons) { lesson in
            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                        Text(lesson.content)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    if lesson.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(category)
    }
}

#Preview {
    NavigationStack {
        LessonListView(category: "Tech")
            .environmentObject(DataStore.shared)
    }
}
