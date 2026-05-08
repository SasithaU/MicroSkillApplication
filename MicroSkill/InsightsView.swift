import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing) {
                Text("Learning Insights")
                    .font(Theme.title())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Personalized analytics based on your study patterns.")
                    .font(Theme.body())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Insight Cards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.spacing) {
                    InsightCard(
                        icon: "clock.fill",
                        iconColor: Theme.accent,
                        title: "Best Time",
                        value: store.bestLearningTime(),
                        subtitle: "Most productive hour"
                    )
                    
                    InsightCard(
                        icon: "calendar.circle.fill",
                        iconColor: Theme.primary,
                        title: "Most Active Day",
                        value: store.mostActiveDay(),
                        subtitle: "You learn most here"
                    )
                    
                    InsightCard(
                        icon: "flame.fill",
                        iconColor: Color.orange,
                        title: "Study Streak",
                        value: "\(store.progress.streak) days",
                        subtitle: "Keep it going!"
                    )
                    
                    InsightCard(
                        icon: "hourglass",
                        iconColor: Theme.success,
                        title: "Study Time",
                        value: "\(store.totalStudyTimeMinutes()) min",
                        subtitle: "Total time invested"
                    )
                    
                    // NEW: Optimal Time Prediction from LearningModel
                    InsightCard(
                        icon: "brain.head.profile",
                        iconColor: Theme.primary,
                        title: "Optimal Time",
                        value: LearningModel.shared.optimalTimeDescription(),
                        subtitle: "AI-predicted best time"
                    )
                    
                    // NEW: Consistency Score
                    let consistency = LearningModel.shared.consistencyScore()
                    InsightCard(
                        icon: "chart.pie.fill",
                        iconColor: consistency > 0.5 ? Theme.success : Theme.accent,
                        title: "Consistency",
                        value: "\(Int(consistency * 100))%",
                        subtitle: consistency > 0.5 ? "Great habits!" : "Keep building"
                    )
                }
                
                // NEW: Readiness for Advanced
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .foregroundColor(Theme.primary)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Advanced Readiness")
                                .font(Theme.headline())
                            Text(LearningModel.shared.isReadyForAdvanced() ? "You're ready for advanced lessons!" : "Complete more lessons to unlock advanced content")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: LearningModel.shared.isReadyForAdvanced() ? "checkmark.seal.fill" : "lock.fill")
                            .font(.title2)
                            .foregroundColor(LearningModel.shared.isReadyForAdvanced() ? Theme.success : .secondary)
                    }
                }
                .cardStyle()
                
                // NEW: Peak Performance Category
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color.yellow)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Peak Performance")
                                .font(Theme.headline())
                            Text("Your strongest category: \(LearningModel.shared.peakPerformanceCategory())")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .cardStyle()
                
                // Average Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(Theme.primary)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily Average")
                                .font(Theme.headline())
                            Text("Lessons completed per day (last 7 days)")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", store.averageLessonsPerDay()))
                            .font(Theme.title())
                            .foregroundColor(Theme.primary)
                    }
                }
                .cardStyle()
                
                // Category Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category Breakdown")
                        .font(Theme.headline())
                    
                    ForEach(store.categoryBreakdown(), id: \.category) { item in
                        HStack {
                            Text(item.category)
                                .font(Theme.body())
                            Spacer()
                            Text("\(item.count)")
                                .font(Theme.headline())
                                .foregroundColor(Theme.primary)
                        }
                        
                        GeometryReader { geo in
                            let total = max(store.completedLessonsCount, 1)
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.primary)
                                    .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(total), height: 8)
                                    .animation(.easeInOut(duration: 0.5), value: item.count)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .cardStyle()
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 8)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 10) {
            IconTile(systemName: icon, color: iconColor)
            
            Text(value)
                .font(Theme.headline())
                .multilineTextAlignment(.center)
            
            Text(title)
                .font(Theme.caption())
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        InsightsView()
            .environmentObject(DataStore.shared)
    }
}
