import SwiftUI

struct LessonListView: View {
    let category: String
    @State private var lessons: [Lesson] = []
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    ForEach(lessons) { lesson in
                        LessonRow(lesson: lesson)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                lessons = DummyData.lessons.filter { $0.category == category }
            }
        }
    }
}

struct LessonRow: View {
    let lesson: Lesson
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion Indicator
            ZStack {
                Circle()
                    .fill(lesson.isCompleted ? Theme.success.opacity(0.15) : Theme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: lesson.isCompleted ? "checkmark" : "\(lesson.order)")
                    .font(lesson.isCompleted ? .title3.weight(.bold) : .body.weight(.semibold))
                    .foregroundStyle(lesson.isCompleted ? Theme.success : Theme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(Theme.headline())
                    .foregroundColor(.primary)
                
                Text(lesson.content)
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.success)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        LessonListView(category: "Tech")
    }
}
