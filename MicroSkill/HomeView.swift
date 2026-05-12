import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: DataStore

    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    


    private var nextLesson: Lesson? {
        store.firstIncompleteLesson()
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
                                
                                Text(store.progress.userName ?? "User")
                                    .font(Theme.largeTitle())
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(value: HomeDestination.profile) {
                                if let data = store.progress.profileImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Theme.primary.opacity(0.2), lineWidth: 1))
                                        .premiumShadow()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Theme.primary)
                                        .background(Circle().fill(.ultraThinMaterial))
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Profile")
                            .accessibilityHint("View your profile and account settings")
                        }
                        

                        Text("MASTERING \(store.activeSubject?.uppercased() ?? "SKILL")")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.heroGradient)
                            .clipShape(Capsule())
                            .premiumShadow()
                    }
                    .padding(.top, 20)
                    
                    #if DEBUG
                    Button("DEBUG: Print State") {
                        print("[DEBUG] Active Subject: \(store.activeSubject ?? "nil")")
                        print("[DEBUG] Mapped Category: \(store.activeSubject != nil ? DataStore.shared.getInternalCategory(for: store.activeSubject!) : "nil")")
                        print("[DEBUG] Lessons Count: \(store.lessons.count)")
                        for lesson in store.lessons {
                            print("  - [\(lesson.category)] \(lesson.title)")
                        }
                    }
                    .buttonStyle(.bordered)
                    #endif
                    
                    // Goal Mastery Progress
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Subject Progress")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                Text(store.activeSubject ?? "Select a Subject")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            Text("\(Int(progressValue * 100))%")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.primary)
                        }
                        
                        ProgressView(value: progressValue)
                            .tint(Theme.primary)
                            .frame(height: 10)
                    }
                    .glassCardStyle()
                    .accessibilityLabel("Current focus: \(store.activeSubject ?? "Skill")")
                    
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
                    // Finish Subject Button
                    VStack(spacing: 24) {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.vertical, 10)
                        
                        VStack(spacing: 12) {
                            Text("Ready for your next challenge?")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                withAnimation {
                                    store.finishCurrentSubject()
                                }
                            }) {
                                HStack {
                                    Text("Finish Learning Subject")
                                    Image(systemName: "checkmark.seal.fill")
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(.bottom, 40)
                    }
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
