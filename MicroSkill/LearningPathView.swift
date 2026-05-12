import SwiftUI

struct LearningPathView: View {
    @EnvironmentObject var store: DataStore
    
    private var overallProgress: Double {
        let completed = store.lessons.filter(\.isCompleted).count
        return store.lessons.isEmpty ? 0 : Double(completed) / Double(store.lessons.count)
    }
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: Theme.spacing * 2) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Learning Path")
                            .font(Theme.largeTitle())
                            .foregroundColor(.primary)
                        
                        Text("Master micro-skills sequentially to achieve your goals.")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    // Overall Progress Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Global Progress")
                                    .font(Theme.headline())
                                Text("\(store.lessons.filter(\.isCompleted).count) of \(store.lessons.count) Lessons Completed")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(Int(overallProgress * 100))%")
                                .font(Theme.title())
                                .foregroundStyle(Theme.primary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(height: 14)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.heroGradient)
                                    .frame(width: geo.size.width * overallProgress, height: 14)
                                    .shadow(color: Theme.primary.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                        }
                        .frame(height: 14)
                        .accessibilityLabel("Overall mastery progress: \(Int(overallProgress * 100))%")
                    }
                    .glassCardStyle()
                    
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
                    .padding(.top, 10)
                    
                    // Next Level Button
                    if overallProgress == 1.0 {
                        Button(action: {
                            withAnimation {
                                store.generateMoreLessons()
                            }
                        }) {
                            HStack {
                                if store.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                    Text("Architecting Next Level...")
                                } else {
                                    Text("Load Next Level")
                                    Image(systemName: "sparkles")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.vertical, 20)
                        .disabled(store.isLoading)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                    NavigationLink(value: lesson) {
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
                NavigationLink(value: lesson) {
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
                    Text(lesson.category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isUnlocked ? Theme.primary : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isUnlocked ? Theme.primary.opacity(0.12) : Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Text(lesson.title)
                        .font(Theme.headline())
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    Text(lesson.content)
                        .font(Theme.body())
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if lesson.isCompleted {
                    ZStack {
                        Circle().fill(Theme.success.opacity(0.1)).frame(width: 32, height: 32)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.success)
                            .font(.title3)
                    }
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondary.opacity(0.5))
                        .font(.title3)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.primary)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            
            if isUnlocked && !lesson.isCompleted {
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                        Text("Start Lesson")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.heroGradient)
                    .clipShape(Capsule())
                    .premiumShadow()
                }
            }
        }
        .glassCardStyle()
        .opacity(isUnlocked ? 1.0 : 0.6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lesson.title), \(lesson.category). \(lesson.isCompleted ? "Completed" : (isUnlocked ? "Unlocked" : "Locked"))")
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
                .font(.system(size: isUnlocked ? 18 : 14, weight: .bold))
                .foregroundColor(nodeIconColor)
        }
        .frame(width: 48, height: 48)
        .accessibilityHidden(true)
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
        lesson.isCompleted ? Theme.success : (isUnlocked ? Theme.primary.opacity(0.4) : Color.secondary.opacity(0.15))
    }
}

#Preview {
    NavigationStack {
        LearningPathView()
            .environmentObject(DataStore.shared)
    }
}
