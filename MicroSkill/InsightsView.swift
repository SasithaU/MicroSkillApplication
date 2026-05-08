import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal Insights")
                            .font(Theme.largeTitle())
                        Text("Data-driven analytics to optimize your learning")
                            .font(Theme.body())
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        InsightCard(
                            icon: "clock.fill",
                            iconColor: Theme.accent,
                            title: "Peak Hour",
                            value: store.bestLearningTime(),
                            subtitle: "Most active time"
                        )
                        .accessibilityLabel("Peak learning hour: \(store.bestLearningTime())")
                        
                        InsightCard(
                            icon: "calendar.badge.clock",
                            iconColor: Theme.primary,
                            title: "Best Day",
                            value: store.mostActiveDay(),
                            subtitle: "Peak performance"
                        )
                        .accessibilityLabel("Most active day: \(store.mostActiveDay())")
                        
                        InsightCard(
                            icon: "brain.head.profile",
                            iconColor: Theme.secondaryAccent,
                            title: "Optimal Time",
                            value: LearningModel.shared.optimalTimeDescription(),
                            subtitle: "AI Recommendation"
                        )
                        .accessibilityLabel("Optimal learning time: \(LearningModel.shared.optimalTimeDescription())")
                        
                        InsightCard(
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: Theme.success,
                            title: "Consistency",
                            value: "\(Int(LearningModel.shared.consistencyScore() * 100))%",
                            subtitle: "Study habit score"
                        )
                        .accessibilityLabel("Consistency score: \(Int(LearningModel.shared.consistencyScore() * 100))%")
                    }
                    
                    // Readiness Section
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.primary.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: LearningModel.shared.isReadyForAdvanced() ? "checkmark.seal.fill" : "lock.fill")
                                .foregroundStyle(Theme.primary)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Advanced Readiness")
                                .font(Theme.headline())
                            Text(LearningModel.shared.isReadyForAdvanced() ? "You're ready for advanced content!" : "Master more lessons to unlock")
                                .font(Theme.caption())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .glassCardStyle()
                    
                    // Category Performance
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Topic Mastery")
                            .font(Theme.headline())
                        
                        ForEach(store.categoryBreakdown(), id: \.category) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(item.category)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    Spacer()
                                    Text("\(item.count) Lessons")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Theme.primary)
                                }
                                
                                GeometryReader { geo in
                                    let total = max(store.completedLessonsCount, 1)
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.primary.opacity(0.05))
                                            .frame(height: 10)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Theme.heroGradient)
                                            .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(total), height: 10)
                                    }
                                }
                                .frame(height: 10)
                                .accessibilityLabel("\(item.category) mastery progress: \(item.count) lessons completed")
                            }
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InsightCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.system(size: 14, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .premiumShadow()
    }
}

#Preview {
    NavigationStack {
        InsightsView()
            .environmentObject(DataStore.shared)
    }
}
