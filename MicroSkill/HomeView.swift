import SwiftUI

struct HomeView: View {
    @State private var userName = UserDefaults.standard.string(forKey: "userName") ?? "User"
    @State private var lessons: [Lesson] = DummyData.lessons
    @State private var streak: Int = 3
    
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
        lessons.first { !$0.isCompleted }
    }
    
    private var progressValue: Double {
        let completed = lessons.filter(\.isCompleted).count
        return lessons.isEmpty ? 0 : Double(completed) / Double(lessons.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacing * 1.5) {
                        // Greeting Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(userName)
                                .font(Theme.largeTitle())
                                .foregroundStyle(Theme.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        
                        // Streak Card
                        HStack(spacing: 12) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.accent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(streak) Day Streak")
                                    .font(Theme.headline())
                                    .foregroundColor(.primary)
                                
                                Text("Keep it up!")
                                    .font(Theme.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .fill(Theme.accent.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                .stroke(Theme.accent.opacity(0.2), lineWidth: 1)
                        )
                        
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
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Theme.heroGradient)
                                        .frame(width: geo.size.width * progressValue, height: 12)
                                        .animation(.easeInOut(duration: 0.6), value: progressValue)
                                }
                            }
                            .frame(height: 12)
                            
                            Text("\(lessons.filter(\.isCompleted).count) of \(lessons.count) lessons completed")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .cardStyle()
                        
                        // Continue Learning
                        if let lesson = nextLesson {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Continue Learning")
                                    .font(Theme.headline())
                                
                                NavigationLink(destination: Text("Lesson Detail - Coming in Turn 2")) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(lesson.category)
                                                .font(Theme.caption())
                                                .foregroundStyle(Theme.primary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Theme.primary.opacity(0.12))
                                                .cornerRadius(8)
                                            
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
                                                .foregroundStyle(Theme.heroGradient)
                                            Text("Resume")
                                                .font(Theme.caption())
                                                .foregroundStyle(Theme.primary)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding()
                                    .background(Theme.cardBackground)
                                    .cornerRadius(Theme.cardCornerRadius)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                                            .stroke(Theme.primary.opacity(0.15), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
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
}
