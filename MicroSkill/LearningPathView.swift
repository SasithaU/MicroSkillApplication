import SwiftUI

struct LearningPathView: View {
    @EnvironmentObject var store: DataStore
    
    private var overallProgress: Double {
        let completed = store.lessons.filter(\.isCompleted).count
        return store.lessons.isEmpty ? 0 : Double(completed) / Double(store.lessons.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing * 1.5) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Learning Path")
                            .font(Theme.title())
                            .foregroundColor(.primary)
                        
                        Text("Complete lessons sequentially to unlock the next.")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Overall Progress
                    VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Overall Progress")
                            .font(Theme.headline())
                        Spacer()
                        Text("\(Int(overallProgress * 100))%")
                            .font(Theme.headline())
                            .foregroundStyle(Theme.primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Theme.heroGradient)
                                .frame(width: geo.size.width * overallProgress, height: 12)
                                .animation(.easeInOut(duration: 0.6), value: overallProgress)
                        }
                    }
                    .frame(height: 12)
                }
                .padding()
                .cardStyle()
                
                // Lesson Nodes
                VStack(spacing: 0) {
                    ForEach(Array(store.lessons.enumerated()), id: \.element.id) { index, lesson in
                        let unlocked = store.isLessonUnlocked(lesson)
                        let isLast = index == store.lessons.count - 1
                        
                        LessonNodeView(
                            lesson: lesson,
                            index: index,
                            isUnlocked: unlocked,
                            isLast: isLast
                        )
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 8)
        }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Learning Path")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Lesson.self) { selectedLesson in
                LessonDetailView(lesson: selectedLesson)
            }
        }
    }
}

// MARK: - Lesson Node

struct LessonNodeView: View {
    let lesson: Lesson
    let index: Int
    let isUnlocked: Bool
    let isLast: Bool
    
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline column
            VStack(spacing: 0) {
                // Node circle
                ZStack {
                    Circle()
                        .fill(nodeBackground)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .stroke(nodeStrokeColor, lineWidth: 3)
                        .frame(width: 48, height: 48)
                    
                    nodeIcon
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(nodeIconColor)
                }
                .frame(width: 48, height: 48)
                
                // Connector line to next node
                if !isLast {
                    Rectangle()
                        .fill(connectorColor)
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 48)
            
            // Card
            if isUnlocked {
                NavigationLink(value: lesson) {
                    lessonCard
                }
                .buttonStyle(.plain)
            } else {
                lessonCard
                    .opacity(0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var lessonCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.category)
                    .font(Theme.caption())
                    .foregroundColor(isUnlocked ? Theme.primary : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(isUnlocked ? Theme.primary.opacity(0.12) : Color.secondary.opacity(0.1))
                    .cornerRadius(6)
                
                Text(lesson.title)
                    .font(Theme.headline())
                    .foregroundColor(.primary)
                
                Text(lesson.content)
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.success)
                    .font(.title3)
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.title3)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.primary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .stroke(lesson.isCompleted ? Theme.success.opacity(0.3) : isUnlocked ? Theme.primary.opacity(0.15) : Color.secondary.opacity(0.1), lineWidth: 1.5)
        )
    }
    
    // MARK: - Node Styling
    
    private var nodeBackground: Color {
        if lesson.isCompleted {
            return Theme.success.opacity(0.15)
        } else if isUnlocked {
            return Theme.primary.opacity(0.15)
        } else {
            return Color.secondary.opacity(0.1)
        }
    }
    
    private var nodeStrokeColor: Color {
        if lesson.isCompleted {
            return Theme.success
        } else if isUnlocked {
            return Theme.primary
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
    
    private var nodeIconColor: Color {
        if lesson.isCompleted {
            return Theme.success
        } else if isUnlocked {
            return Theme.primary
        } else {
            return Color.secondary
        }
    }
    
    private var nodeIcon: some View {
        if lesson.isCompleted {
            return Image(systemName: "checkmark")
        } else if isUnlocked {
            return Image(systemName: "\(index + 1).circle")
        } else {
            return Image(systemName: "lock")
        }
    }
    
    private var connectorColor: Color {
        lesson.isCompleted ? Theme.success : Color.secondary.opacity(0.2)
    }
}

#Preview {
    NavigationStack {
        LearningPathView()
            .environmentObject(DataStore.shared)
    }
}
