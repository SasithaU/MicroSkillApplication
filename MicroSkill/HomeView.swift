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
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: Theme.spacing * 1.8) {
                    // Hero Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(Theme.body())
                                    .foregroundColor(.secondary)
                                
                                Text(userName)
                                    .font(Theme.largeTitle())
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(value: HomeDestination.profile) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.primary)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Profile")
                            .accessibilityHint("View your profile and account settings")
                        }
                        
                        Text("Personalized for \(userGoal)")
                            .font(Theme.caption())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.heroGradient)
                            .clipShape(Capsule())
                            .accessibilityLabel("Learning goal: \(userGoal)")
                    }
                    .padding(.top, 20)
                    
                    // Focus Preference Card
                    HStack(spacing: 16) {
                        IconTile(systemName: "line.3.horizontal.decrease.circle.fill", color: Theme.primary, isGlass: true)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Focus")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text(preferredCategory)
                                .font(Theme.headline())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .glassCardStyle()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Current focus: \(preferredCategory)")
                    
                    // Progress & Streak Row
                    HStack(spacing: Theme.spacing) {
                        // Streak
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("Streak")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(store.progress.streak) Days")
                                .font(Theme.title())
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(store.progress.streak) day streak")
                        
                        // Mastery Points
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.yellow)
                                Text("Points")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(store.progress.totalPoints)")
                                .font(Theme.title())
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(store.progress.totalPoints) mastery points")
                    }
                    
                    // Main Progress Overview
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Global Mastery")
                                .font(Theme.headline())
                            
                            Spacer()
                            
                            Text("\(Int(progressValue * 100))%")
                                .font(Theme.headline())
                                .foregroundStyle(Theme.primary)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(height: 14)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.heroGradient)
                                    .frame(width: geo.size.width * progressValue, height: 14)
                                    .shadow(color: Theme.primary.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                        }
                        .frame(height: 14)
                        .accessibilityLabel("Mastery progress: \(Int(progressValue * 100))%")
                        
                        HStack {
                            Text("\(store.lessons.filter(\.isCompleted).count) Lessons Completed")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            NavigationLink(value: HomeDestination.learningPath) {
                                Text("View Path")
                                    .font(Theme.caption())
                                    .foregroundStyle(Theme.primary)
                            }
                        }
                    }
                    .cardStyle()
                    
                    // Recommendations Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recommended for You")
                                .font(Theme.headline())
                            Spacer()
                            Image(systemName: "sparkles")
                                .foregroundStyle(Theme.accent)
                        }
                        
                        let recommendation = LearningModel.shared.personalizedRecommendation()
                        Text(recommendation)
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.accent.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .accessibilityLabel("Learning recommendation: \(recommendation)")
                    }
                    
                    // Continue Learning Card
                    if let lesson = nextLesson {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Up Next")
                                .font(Theme.headline())
                            
                            NavigationLink(value: HomeDestination.lessonDetail(lesson, categoryLimit: nil)) {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(lesson.category.uppercased())
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Theme.primary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Theme.primary.opacity(0.1))
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
                                    
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundStyle(Theme.heroGradient)
                                }
                                .padding(Theme.padding)
                                .background(Color.white.opacity(0.05))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                        .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
                                )
                                .premiumShadow()
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Continue learning: \(lesson.title)")
                            .accessibilityHint("Double tap to start the next lesson in \(lesson.category)")
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(DataStore.shared)
    }
}
