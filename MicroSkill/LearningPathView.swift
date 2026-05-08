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
                                    .fill(Theme.primary)
                                    .frame(width: geo.size.width * overallProgress, height: 12)
                                    .animation(.snappy(duration: 0.6), value: overallProgress)
                            }
                        }
                        .frame(height: 12)
                    }
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
        HStack(alignment: .top, spacing: 16) {
            // Timeline column
            VStack(spacing: 0) {
                if isUnlocked && !lesson.isCompleted {
                    NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                        nodeCircle
                    }
                    .buttonStyle(.plain)
                } else {
                    nodeCircle
                }
                
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
            if isUnlocked && !lesson.isCompleted {
                NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                    lessonCard
                }
                .buttonStyle(.plain)
            } else {
                lessonCard
                    .opacity(isUnlocked ? 1.0 : 0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var lessonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.category)
                        .font(Theme.caption())
                        .foregroundColor(isUnlocked ? Theme.primary : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isUnlocked ? Theme.primary.opacity(0.12) : Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                    
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
            
            if isUnlocked && !lesson.isCompleted {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                        Text("Proceed to Lesson")
                    }
                    .font(Theme.caption().bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.primary)
                    .clipShape(Capsule())
                }
            }
        }
        .cardStyle()
    }
    
    private var nodeCircle: some View {
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
            Image(systemName: "checkmark")
        } else if isUnlocked {
            Image(systemName: "\(index + 1).circle")
        } else {
            Image(systemName: "lock")
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
