import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: DataStore
    @State private var userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
    @AppStorage("userGoal") private var userGoal = "Tech Skills"
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    private var preferredCategory: String {
        switch userGoal {
        case "Tech Skills":
            return "Tech"
        case "Productivity":
            return "Productivity"
        case "General Knowledge":
            return "General Knowledge"
        default:
            return "Tech"
        }
    }

    private var nextLesson: Lesson? {
        store.firstIncompleteLesson(inCategory: preferredCategory) ?? store.firstIncompleteLesson()
    }
    
    private var progressValue: Double {
        let completed = store.lessons.filter(\.isCompleted).count
        return store.lessons.isEmpty ? 0 : Double(completed) / Double(store.lessons.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing * 1.5) {
                        // Greeting Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(greeting), \(userName)")
                                .font(Theme.largeTitle())
                                .foregroundColor(.primary)
                            
                            Text("Personalized for \(userGoal).")
                                .font(Theme.body())
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                        HStack(spacing: 10) {
                            IconTile(systemName: "line.3.horizontal.decrease.circle.fill", color: Theme.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Focus Preference")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                Text("Next lessons prioritize \(preferredCategory). You can change this in Settings.")
                                    .font(Theme.body())
                                    .foregroundColor(.primary)
                            }

                            Spacer()
                        }
                        .cardStyle()
                        
                        // Streak Card
                        HStack(spacing: 12) {
                            IconTile(systemName: "flame.fill", color: .orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(store.progress.streak) Day Streak")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                                
                                Text("Keep it up!")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .cardStyle()
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(store.progress.streak) day learning streak. Keep it up!")
                        
                        // Progress Overview
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Your Progress")
                                    .font(Theme.headline())
                                
                                Spacer()
                                
                                Text("\(Int(progressValue * 100))%")
                                    .font(Theme.headline())
                                    .foregroundStyle(Theme.primary)
                            }

                            Text(progressValue >= 1 ? "Complete" : "In progress")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Theme.primary)
                                        .frame(width: geo.size.width * progressValue, height: 12)
                                        .animation(.snappy(duration: 0.6), value: progressValue)
                                }
                            }
                            .frame(height: 12)
                            .accessibilityHidden(true)
                            
                            Text("\(store.lessons.filter(\.isCompleted).count) of \(store.lessons.count) lessons completed")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        .cardStyle()
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Your progress is \(Int(progressValue * 100)) percent. \(store.lessons.filter(\.isCompleted).count) of \(store.lessons.count) lessons completed.")
                        
                        // View Learning Path
                        NavigationLink(destination: LearningPathView()) {
                            HStack(spacing: 12) {
                                IconTile(systemName: "signpost.right.fill", color: Theme.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("View Learning Path")
                                        .font(Theme.headline())
                                        .foregroundColor(.primary)
                                    
                                    Text("See your progress and next steps")
                                        .font(Theme.caption())
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .cardStyle()
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("View Learning Path. See your progress and next steps")
                        
                        // Personalized Recommendation from LearningModel
                        let recommendation = LearningModel.shared.personalizedRecommendation()
                        HStack(spacing: 12) {
                            IconTile(systemName: "sparkles", color: Theme.accent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Personalized Tip")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Text(recommendation)
                                    .font(Theme.body())
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .cardStyle()
                        .accessibilityLabel("Personalized tip: \(recommendation)")
                        
                        // Recommended Category
                        let recommendedCategory = LearningModel.shared.recommendedNextCategory()
                        HStack(spacing: 12) {
                            IconTile(systemName: "arrow.right.circle.fill", color: Theme.primary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recommended Focus")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Text(recommendedCategory)
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .cardStyle()
                        .accessibilityLabel("Recommended focus category: \(recommendedCategory)")
                        
                        // Context-Aware Recommendation
                        if LocationManager.shared.detectedContext != "unknown" {
                            let context = LocationManager.shared.detectedContext
                            let recommendedCategory = LocationManager.shared.recommendedCategory(for: context)
                            let contextLesson = store.firstIncompleteLesson(inCategory: recommendedCategory)
                            
                            if let lesson = contextLesson {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .foregroundStyle(Theme.primary)
                                        Text("Recommended for \(context.capitalized)")
                                            .font(Theme.headline())
                                            .foregroundStyle(Theme.primary)
                                    }
                                    
                                    NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(lesson.category)
                                                    .font(Theme.caption())
                                                    .foregroundStyle(Theme.primary)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Theme.primary.opacity(0.12))
                                                    .clipShape(Capsule())
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Text(lesson.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(lesson.content)
                                                .font(Theme.body())
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "location.circle.fill")
                                                    .foregroundStyle(Theme.primary)
                                                Text("Start Now")
                                                    .font(Theme.caption())
                                                    .foregroundStyle(Theme.primary)
                                            }
                                            .padding(.top, 4)
                                        }
                                        .cardStyle()
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Context recommendation: \(lesson.title) in \(lesson.category) for \(context). Start now.")
                                }
                            }
                        }
                        
                        // Continue Learning or Browse Lessons
                        if let lesson = nextLesson {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Continue Learning")
                                    .font(Theme.headline())

                                Text("Prioritized for your selected focus (\(preferredCategory)).")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                                
                                NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(lesson.category)
                                                .font(Theme.caption())
                                                .foregroundStyle(Theme.primary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Theme.primary.opacity(0.12))
                                                .clipShape(Capsule())
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text(lesson.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(lesson.content)
                                            .font(Theme.body())
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "play.circle.fill")
                                                .foregroundStyle(Theme.primary)
                                            Text("Resume")
                                                .font(Theme.caption())
                                                .foregroundStyle(Theme.primary)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .cardStyle()
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Continue learning: \(lesson.title) in \(lesson.category). Resume lesson.")
                            }
                        } else {
                            // Show Browse Lessons when all lessons are completed
                            VStack(alignment: .leading, spacing: 12) {
                                Text("All Lessons Completed")
                                    .font(Theme.headline())
                                
                                NavigationLink(destination: CategoriesView()) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            IconTile(systemName: "book.fill", color: Theme.primary)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Browse All Lessons")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                Text("Review completed lessons or explore new topics")
                                                    .font(Theme.body())
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.right.circle.fill")
                                                .foregroundStyle(Theme.primary)
                                            Text("Explore")
                                                .font(Theme.caption())
                                                .foregroundStyle(Theme.primary)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .cardStyle()
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Browse all lessons. Review completed lessons or explore new topics.")
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, Theme.padding)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DataStore.shared)
}
