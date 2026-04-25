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
                }
                
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
                .padding()
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
                .padding()
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
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(iconColor)
            
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
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cardCornerRadius)
    }
}

#Preview {
    NavigationStack {
        InsightsView()
            .environmentObject(DataStore.shared)
    }
}

